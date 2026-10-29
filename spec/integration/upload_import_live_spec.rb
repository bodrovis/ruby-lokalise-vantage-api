# frozen_string_literal: true

require 'digest'
require 'net/http'
require 'securerandom'
require 'stringio'
require 'uri'

RSpec.describe 'Vantage upload and import E2E' do # rubocop:disable RSpec/DescribeClass
  let(:project_id) do
    ENV.fetch(
      'LOKALISE_VANTAGE_PROJECT_ID',
      '019d29d9-de47-7a57-ac2d-53194197d213'
    )
  end

  # rubocop:disable-next RSpec/ExampleLength, RSpec/MultipleExpectations
  it 'uploads and imports files using stubbed requests' do
    files = [
      {
        file_name: 'vantage-test.md',
        mime_type: 'text/markdown',
        content: "# Vantage SDK test\n\nHello from the Ruby SDK!\n"
      },
      {
        file_name: 'vantage-test.html',
        mime_type: 'text/html',
        content: '<!DOCTYPE html><html><body>' \
                 '<h1>Vantage SDK test</h1>' \
                 '<p>Hello from the Ruby SDK!</p>' \
                 '</body></html>'
      }
    ]

    batch_id = '3fa85f64-5717-4562-b3fc-2c963f66afa6'
    import_id = '019d29da-4444-7444-8444-444444444444'

    upload_ids = %w[
      019d29da-1111-7111-8111-111111111111
      019d29da-2222-7222-8222-222222222222
    ]

    item_ids = %w[
      019d29da-3333-7333-8333-333333333333
      019d29da-5555-7555-8555-555555555555
    ]

    s3_url = 'https://example-bucket.s3.eu-central-1.amazonaws.com/'
    uploads_path = "projects/#{project_id}/uploads"
    client = nil

    # Step 1: Stage the files.
    staged_items = files.each_with_index.map do |file, index|
      {
        fileName: file[:file_name],
        uploadId: upload_ids[index],
        status: 'UPLOADING',
        upload: {
          url: s3_url,
          fields: {
            'key' => "test/#{file[:file_name]}",
            'Content-Type' => file[:mime_type],
            'Content-MD5' => Digest::MD5.base64digest(file[:content])
          }
        }
      }
    end

    stub_vantage_request(
      method: :post,
      path: uploads_path,
      status: 201,
      body: Oj.dump(
        { data: { batchId: batch_id, uploads: staged_items } },
        mode: :strict
      )
    )

    # Step 2: Stub S3, preserving the real multipart request.
    stub_request(:post, s3_url).to_return(status: 204, body: '')

    # Step 3: Stub upload completion.
    stub_vantage_request(
      method: :post,
      path: "#{uploads_path}/actions/complete",
      status: 202,
      body: ''
    )

    # Step 4: Prepare two upload list responses:
    # first UPLOADED, then IMPORTED.
    uploaded_items = files.each_with_index.map do |file, index|
      {
        uploadId: upload_ids[index],
        batchId: batch_id,
        fileName: file[:file_name],
        size: file[:content].bytesize,
        status: 'UPLOADED',
        wordCount: 8,
        locale: 'en'
      }
    end

    imported_items = uploaded_items.each_with_index.map do |item, index|
      item.merge(status: 'IMPORTED', itemId: item_ids[index])
    end

    meta = {
      count: 2,
      cursor: upload_ids.last,
      hasMore: false
    }

    uploads_url = "https://api.lokalise.com/vantage/v1/#{uploads_path}"

    stub_request(:get, uploads_url)
      .with(query: { 'filter-batch-id' => batch_id })
      .to_return(
        {
          status: 200,
          body: Oj.dump({ data: uploaded_items, meta: meta }, mode: :strict),
          headers: { 'Content-Type' => 'application/json' }
        },
        {
          status: 200,
          body: Oj.dump({ data: imported_items, meta: meta }, mode: :strict),
          headers: { 'Content-Type' => 'application/json' }
        }
      )

    # Step 5: Stub import creation.
    stub_vantage_request(
      method: :post,
      path: "projects/#{project_id}/imports",
      status: 202,
      body: Oj.dump({ data: { importId: import_id } }, mode: :strict)
    )

    # Step 6: Stub translation status.
    stub_vantage_request(
      method: :get,
      path: "projects/#{project_id}/translation-statuses/#{import_id}",
      body: Oj.dump(
        {
          data: {
            projectId: project_id,
            importId: import_id,
            status: 'TRANSLATING',
            languages: [
              {
                languageId: '019d29d9-de52-7ba2-87c6-b5355efd2aa7',
                locale: 'fr',
                status: 'TRANSLATING'
              }
            ]
          }
        },
        mode: :strict
      )
    )

    begin
      client = test_client_vantage('test-token')

      staged = client.stage_uploads(
        project_id,
        uploads: files.map do |file|
          {
            fileName: file[:file_name],
            mimeType: file[:mime_type],
            size: file[:content].bytesize,
            checksum: Digest::MD5.hexdigest(file[:content])
          }
        end
      )

      expect(staged.batch_id).to eq(batch_id)
      expect(staged.uploads.size).to eq(2)

      staged.uploads.each do |item|
        expect(item['error']).to be_nil

        file = files.find { |candidate| candidate[:file_name] == item['fileName'] }
        expect(file).not_to be_nil

        form = upload_to_s3(item, file)

        # Verify all S3 fields were preserved.
        item['upload']['fields'].each do |key, value|
          expect(form).to include([key, value.to_s])
        end

        # Verify the actual file part.
        file_part = form.find { |entry| entry.first == 'file' }

        expect(file_part).not_to be_nil
        expect(file_part[2]).to include(
          filename: file[:file_name],
          content_type: file[:mime_type]
        )

        file_part[1].rewind
        expect(file_part[1].string).to eq(file[:content])
      end

      expect(a_request(:post, s3_url)).to have_been_made.twice

      completed = client.complete_uploads(
        project_id,
        batchId: staged.batch_id
      )

      expect(completed).to be_nil

      uploaded = wait_for_uploads(
        client,
        batch_id,
        upload_ids,
        target: 'UPLOADED'
      )

      expect(uploaded.map(&:upload_id)).to match_array(upload_ids)
      expect(uploaded).to all(have_attributes(
                                batch_id: batch_id,
                                status: 'UPLOADED',
                                item_id: nil
                              ))

      imported = client.create_import(
        project_id,
        batchId: staged.batch_id
      )

      expect(imported.import_id).to eq(import_id)

      imported_uploads = wait_for_uploads(
        client,
        batch_id,
        upload_ids,
        target: 'IMPORTED'
      )

      expect(imported_uploads.map(&:item_id)).to match_array(item_ids)
      expect(imported_uploads).to all(have_attributes(status: 'IMPORTED'))

      translation = client.translation_status(project_id, imported.import_id)

      expect(translation.project_id).to eq(project_id)
      expect(translation.import_id).to eq(import_id)
      expect(translation.status).to eq('TRANSLATING')
      expect(translation.languages.size).to eq(1)
      expect(translation.languages.first['locale']).to eq('fr')
      expect(translation.languages.first['status']).to eq('TRANSLATING')

      expect(
        a_request(:post, uploads_url).with do |request|
          body = Oj.load(request.body)
          submitted = body.fetch('uploads')

          submitted.size == files.size &&
            submitted.zip(files).all? do |entry, file|
              entry['fileName'] == file[:file_name] &&
                entry['size'] == file[:content].bytesize &&
                entry['checksum'] == Digest::MD5.hexdigest(file[:content])
            end
        end
      ).to have_been_made.once

      expect(a_request(:post, s3_url)).to have_been_made.twice
      expect(
        a_request(:get, uploads_url).with(
          query: { 'filter-batch-id' => batch_id }
        )
      ).to have_been_made.twice
    ensure
      client&.close
    end
  end

  def wait_for_uploads(client, batch_id, upload_ids, target:, timeout: 180)
    deadline = calculate_deadline_for(timeout)

    loop do
      items = get_uploads(client, batch_id, upload_ids)

      if items.size == upload_ids.size &&
         items.all? { |upload| upload.status == target }
        return items
      end

      check_deadline(items, deadline, target)
      sleep 3
    end
  end

  def get_uploads(client, batch_id, upload_ids)
    uploads = client.uploads(
      project_id,
      'filter-batch-id': batch_id
    )

    items = uploads.select do |upload|
      upload_ids.include?(upload.upload_id)
    end

    failed = items.find do |upload|
      %w[UPLOAD_FAILED IMPORT_FAILED].include?(upload.status)
    end

    raise "Upload #{failed.file_name} failed: #{failed.error.inspect}" if failed

    items
  end

  def check_deadline(items, deadline, target)
    now = Process.clock_gettime(Process::CLOCK_MONOTONIC)

    return if now < deadline

    states = items.map { |upload| "#{upload.file_name}: #{upload.status}" }
    raise "Timed out waiting for #{target}. Current states: #{states.inspect}"
  end

  def calculate_deadline_for(timeout)
    Process.clock_gettime(Process::CLOCK_MONOTONIC) + timeout
  end

  def upload_to_s3(staged_upload, file)
    target = staged_upload.fetch('upload')
    fields = target.fetch('fields')
    uri = URI.parse(target.fetch('url'))

    raise 'Expected HTTPS upload URL' unless uri.is_a?(URI::HTTPS)

    expect(fields.fetch('Content-MD5')).to eq(
      Digest::MD5.base64digest(file[:content])
    )

    form = make_form(file, fields)
    send_request(uri, form)

    form
  end

  def make_form(file, fields)
    form = fields.map do |key, value|
      [key, value.to_s]
    end

    form << ['Content-Type', file[:mime_type]] unless fields.key?('Content-Type')

    form << [
      'file',
      StringIO.new(file[:content]),
      {
        filename: file[:file_name],
        content_type: file[:mime_type]
      }
    ]
  end

  def send_request(uri, form)
    request = Net::HTTP::Post.new(uri)
    request.set_form(form, 'multipart/form-data')

    response = Net::HTTP.start(
      uri.host,
      uri.port,
      use_ssl: true,
      open_timeout: 15,
      read_timeout: 60,
      write_timeout: 60
    ) do |http|
      http.request(request)
    end

    expect(response.code.to_i).to eq(204)
  end
end

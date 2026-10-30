# frozen_string_literal: true

require 'digest'

RSpec.describe LokaliseApiNext::Rest::Vantage::Uploads do
  let(:project_id) { '019d29d9-de47-7a57-ac2d-53194197d213' }
  let(:path) { "projects/#{project_id}/uploads" }
  let(:url) { "https://api.lokalise.com/vantage/v1/#{path}" }
  let(:content) { '{"hello":"world"}' }

  describe '#uploads' do
    let(:batch_id) { '3fa85f64-5717-4562-b3fc-2c963f66afa6' }

    # rubocop:disable-next RSpec/MultipleExpectations
    it 'returns a collection of uploads' do
      stub_vantage_request(
        method: :get,
        path: path,
        fixture: 'uploads/list.json'
      )

      uploads = test_client_vantage('test-token').uploads(project_id)

      expect(uploads).to be_a(LokaliseApiNext::Collections::Vantage::Uploads)
      expect(uploads.size).to eq(2)
      expect(uploads).to all(be_a(LokaliseApiNext::Models::Vantage::Upload))

      expect(uploads.meta_count).to eq(2)
      expect(uploads.cursor).to eq('019d29da-2222-7222-8222-222222222222')
      expect(uploads.more?).to be true

      upload = uploads.first

      expect(upload.upload_id).to eq('019d29da-1111-7111-8111-111111111111')
      expect(upload.batch_id).to eq(batch_id)
      expect(upload.file_name).to eq('en.json')
      expect(upload.size).to eq(256)
      expect(upload.created_at).to eq('2026-10-28T18:02:48.056Z')
      expect(upload.status).to eq('UPLOADED')
      expect(upload.word_count).to eq(25)
      expect(upload.locale).to eq('en')
      expect(upload.item_id).to be_nil
      expect(upload.error).to be_nil

      failed = uploads.last

      expect(failed.file_name).to eq('broken.json')
      expect(failed.status).to eq('UPLOAD_FAILED')
      expect(failed.error).to eq(
        'code' => 'UPLOAD_FAILED',
        'message' => 'File validation failed'
      )
      expect(failed.word_count).to be_nil
      expect(failed.locale).to be_nil
      expect(failed.item_id).to be_nil
    end

    it 'supports pagination and batch filtering' do
      cursor = '019d29da-2222-7222-8222-222222222222'

      stub_vantage_request(
        method: :get,
        path: path,
        query: {
          limit: 1,
          after: cursor,
          'filter-batch-id': batch_id
        },
        fixture: 'uploads/list_paginated.json'
      )

      uploads = test_client_vantage('test-token').uploads(
        project_id,
        limit: 1,
        after: cursor,
        'filter-batch-id': batch_id
      )

      expect(uploads.size).to eq(1)
      expect(uploads.first).to be_a(LokaliseApiNext::Models::Vantage::Upload)
      expect(uploads.first.batch_id).to eq(batch_id)
      expect(uploads.first.file_name).to eq('fr.json')
      expect(uploads.first.status).to eq('IMPORTED')
      expect(uploads.first.item_id).to eq('019d29da-4444-7444-8444-444444444444')

      expect(uploads.meta_count).to eq(1)
      expect(uploads.cursor).to eq('019d29da-3333-7333-8333-333333333333')
      expect(uploads.more?).to be false
    end
  end

  describe '#stage_uploads' do
    it 'stages files and preserves individual upload errors' do
      stub_vantage_request(
        method: :post,
        path: path,
        fixture: 'uploads/stage.json'
      )

      params = {
        uploads: [
          {
            fileName: 'en.json',
            mimeType: 'application/json',
            size: content.bytesize,
            checksum: Digest::MD5.hexdigest(content)
          },
          {
            fileName: 'unsupported.exe',
            mimeType: 'application/octet-stream',
            size: content.bytesize,
            checksum: Digest::MD5.hexdigest(content)
          }
        ]
      }

      batch = test_client_vantage('test-token').stage_uploads(project_id, params)

      expect(batch).to be_a(LokaliseApiNext::Models::Vantage::UploadBatch)
      expect(batch.batch_id).to eq('3fa85f64-5717-4562-b3fc-2c963f66afa6')
      expect(batch.uploads.size).to eq(2)
      expect(batch.warnings).to be_empty

      upload = batch.uploads.first

      expect(upload['fileName']).to eq('en.json')
      expect(upload['uploadId']).to eq('019d29da-1111-7111-8111-111111111111')
      expect(upload['status']).to eq('UPLOADING')
      expect(upload['upload']['url']).to eq('https://example.com/upload')
      expect(upload['upload']['fields']).to eq(
        'key' => 'test/en.json',
        'policy' => 'test-policy'
      )
      expect(upload['upload']['expiresAt']).to eq('2026-10-28T20:00:00.000Z')

      rejected = batch.uploads.last

      expect(rejected['fileName']).to eq('unsupported.exe')
      expect(rejected['error']['code']).to eq('UNSUPPORTED_FILE_EXTENSION')
      expect(rejected['error']['message']).to eq('Unsupported file extension')

      expect(
        a_request(:post, url).with(
          body: Oj.dump(params, mode: :strict),
          headers: { 'Content-Type' => 'application/json' }
        )
      ).to have_been_made.once
    end

    it 'adds files to an existing upload batch' do
      stub_vantage_request(
        method: :post,
        path: path,
        fixture: 'uploads/stage_existing_batch.json'
      )

      batch_id = '3fa85f64-5717-4562-b3fc-2c963f66afa6'

      params = {
        batchId: batch_id,
        uploads: [
          {
            fileName: 'fr.json',
            mimeType: 'application/json',
            size: content.bytesize,
            checksum: Digest::MD5.hexdigest(content)
          }
        ]
      }

      batch = test_client_vantage('test-token').stage_uploads(project_id, params)

      expect(batch).to be_a(LokaliseApiNext::Models::Vantage::UploadBatch)
      expect(batch.batch_id).to eq(batch_id)
      expect(batch.uploads.size).to eq(1)

      upload = batch.uploads.first

      expect(upload['fileName']).to eq('fr.json')
      expect(upload['uploadId']).to eq('019d29da-2222-7222-8222-222222222222')
      expect(upload['status']).to eq('UPLOADING')
      expect(upload['upload']['url']).to eq('https://example.com/upload')

      expect(
        a_request(:post, url).with(
          body: Oj.dump(params, mode: :strict),
          headers: { 'Content-Type' => 'application/json' }
        )
      ).to have_been_made.once
    end
  end

  describe '#complete_uploads' do
    let(:complete_path) { "#{path}/actions/complete" }
    let(:complete_url) do
      "https://api.lokalise.com/vantage/v1/#{complete_path}"
    end

    it 'completes uploads by batch ID' do
      params = {
        batchId: '3fa85f64-5717-4562-b3fc-2c963f66afa6'
      }

      stub_vantage_request(
        method: :post,
        path: complete_path,
        status: 202,
        body: ''
      )

      result = test_client_vantage('test-token').complete_uploads(project_id, params)

      expect(result).to be_nil

      expect(
        a_request(:post, complete_url).with(
          body: Oj.dump(params, mode: :strict),
          headers: { 'Content-Type' => 'application/json' }
        )
      ).to have_been_made.once
    end

    it 'completes specific uploads' do
      params = {
        uploads: [
          { uploadId: '019d29da-1111-7111-8111-111111111111' },
          { uploadId: '019d29da-2222-7222-8222-222222222222' }
        ]
      }

      stub_vantage_request(
        method: :post,
        path: complete_path,
        status: 202,
        body: ''
      )

      result = test_client_vantage('test-token').complete_uploads(project_id, params)

      expect(result).to be_nil

      expect(
        a_request(:post, complete_url).with(
          body: Oj.dump(params, mode: :strict),
          headers: { 'Content-Type' => 'application/json' }
        )
      ).to have_been_made.once
    end
  end
end

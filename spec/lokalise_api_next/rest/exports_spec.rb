# frozen_string_literal: true

RSpec.describe LokaliseApiNext::Rest::Exports do
  let(:project_id) { '019d29d9-de47-7a57-ac2d-53194197d213' }
  let(:path) { "projects/#{project_id}/exports" }
  let(:url) { "https://api.lokalise.com/vantage/v1/#{path}" }

  describe '#exports' do
    it 'returns a collection of exports' do
      stub_vantage_request(
        method: :get,
        path: path,
        fixture: 'exports/list.json'
      )

      exports = test_client('test-token').exports(project_id)

      expect(exports).to be_a(LokaliseApiNext::Collections::Exports)
      expect(exports.size).to eq(2)
      expect(exports).to all(be_a(LokaliseApiNext::Models::Export))

      expect(exports.page_count).to eq(2)
      expect(exports.cursor).to eq('01a18300-4444-df8e-7dd9-9015ca6c4332')
      expect(exports.more?).to be true

      export = exports.first

      expect(export.export_id).to eq('01a18300-4673-dba9-f455-e2e7a99e8768')
      expect(export.status).to eq('COMPLETED')
      expect(export.created_at).to eq('2026-10-28T14:30:00.000Z')
      expect(export.total_items_count).to eq(2)
      expect(export.processed_items_count).to eq(2)
      expect(export.fail_reason).to be_nil

      expect(exports.last.export_id).to eq('01a18300-4444-df8e-7dd9-9015ca6c4332')
      expect(exports.last.status).to eq('IN_PROGRESS')
    end

    it 'supports pagination and status filtering' do
      cursor = '01a18300-4673-dba9-f455-e2e7a99e8768'

      stub_vantage_request(
        method: :get,
        path: path,
        query: {
          limit: 1,
          after: cursor,
          'filter-status': 'COMPLETED'
        },
        fixture: 'exports/list_paginated.json'
      )

      exports = test_client('test-token').exports(
        project_id,
        limit: 1,
        after: cursor,
        'filter-status': 'COMPLETED'
      )

      expect(exports.size).to eq(1)
      expect(exports.first).to be_a(LokaliseApiNext::Models::Export)
      expect(exports.first.export_id).to eq('01a18300-4444-df8e-7dd9-9015ca6c4332')
      expect(exports.first.status).to eq('COMPLETED')
      expect(exports.first.processed_items_count).to eq(10)

      expect(exports.page_count).to eq(1)
      expect(exports.cursor).to eq('01a18300-4444-df8e-7dd9-9015ca6c4332')
      expect(exports.more?).to be false
    end
  end

  describe '#export' do
    it 'retrieves a completed export' do
      export_id = '01a18300-4444-df8e-7dd9-9015ca6c4332'

      stub_vantage_request(
        method: :get,
        path: "projects/#{project_id}/exports/#{export_id}",
        fixture: 'exports/fetch.json'
      )

      export = test_client('test-token').export(project_id, export_id)

      expect(export).to be_a(LokaliseApiNext::Models::Export)
      expect(export.export_id).to eq(export_id)
      expect(export.status).to eq('COMPLETED')
      expect(export.created_at).to eq('2026-10-28T14:30:00.000Z')
      expect(export.total_items_count).to eq(10)
      expect(export.processed_items_count).to eq(10)
      expect(export.fail_reason).to be_nil
      expect(export.warnings).to be_empty
    end

    it 'retrieves a failed export with its failure reason' do
      export_id = '3fa85f64-5717-4562-b3fc-2c963f66afa6'

      stub_vantage_request(
        method: :get,
        path: "projects/#{project_id}/exports/#{export_id}",
        fixture: 'exports/fetch_failed.json'
      )

      export = test_client('test-token').export(project_id, export_id)

      expect(export).to be_a(LokaliseApiNext::Models::Export)
      expect(export.export_id).to eq(export_id)
      expect(export.status).to eq('FAILED')
      expect(export.total_items_count).to eq(0)
      expect(export.processed_items_count).to eq(0)
      expect(export.fail_reason).to eq('No content available for export')
    end
  end

  describe '#create_export' do
    it 'creates a full project export' do
      stub_vantage_request(
        method: :post,
        path: path,
        status: 202,
        fixture: 'exports/create_full.json'
      )

      export = test_client('test-token').create_export(project_id)

      expect(export).to be_a(LokaliseApiNext::Models::Export)
      expect(export.export_id).to eq('01a18300-4444-df8e-7dd9-9015ca6c4332')
      expect(export.status).to eq('IN_PROGRESS')
      expect(export.warnings).to be_empty

      expect(
        a_request(:post, url).with(
          body: Oj.dump({}, mode: :strict),
          headers: { 'Content-Type' => 'application/json' }
        )
      ).to have_been_made.once
    end

    it 'creates an export for a specific locale' do
      stub_vantage_request(
        method: :post,
        path: path,
        status: 202,
        fixture: 'exports/create_french.json'
      )

      export = test_client('test-token').create_export(
        project_id,
        locales: ['fr']
      )

      expect(export).to be_a(LokaliseApiNext::Models::Export)
      expect(export.export_id).to eq('01a18300-4673-dba9-f455-e2e7a99e8768')
      expect(export.status).to eq('IN_PROGRESS')
      expect(export.warnings).to be_empty

      expect(
        a_request(:post, url).with(
          body: Oj.dump({ locales: ['fr'] }, mode: :strict),
          headers: { 'Content-Type' => 'application/json' }
        )
      ).to have_been_made.once
    end
  end

  specify '#export_download_url' do
    export_id = '01a18300-4444-df8e-7dd9-9015ca6c4332'

    stub_vantage_request(
      method: :get,
      path: "projects/#{project_id}/exports/#{export_id}/download-url",
      fixture: 'exports/download_url.json'
    )

    result = test_client('test-token').export_download_url(
      project_id,
      export_id
    )

    expect(result).to be_a(LokaliseApiNext::Models::ExportDownloadUrl)
    expect(result.download_url).to eq(
      'https://example.com/exports/archive.zip?token=test-token'
    )
    expect(result.warnings).to be_empty
  end
end

# frozen_string_literal: true

RSpec.describe LokaliseApiNext::Connection do
  let(:project_id) { 'project-123' }

  describe 'persistent connection' do
    let(:team_id) { 'team-456' }

    it 'performs multiple requests using the same client' do
      stub_vantage_request(
        method: :get,
        path: "/projects/#{project_id}",
        fixture: 'connection/project.json'
      )

      stub_vantage_request(
        method: :get,
        path: "/teams/#{team_id}/projects",
        fixture: 'connection/projects.json'
      )

      client = test_client('test-token', persistent: true, open_timeout: 10, timeout: 10)

      begin
        project = client.project(project_id)
        projects = client.projects(team_id)

        expect(project).to be_a(LokaliseApiNext::Models::Project)
        expect(project.name).to eq('Test project')

        expect(projects).to be_a(LokaliseApiNext::Collections::Projects)
        expect(projects.size).to eq(1)
        expect(projects.first.name).to eq('Test project')
        expect(projects.more?).to be false
      ensure
        client.close
      end
    end
  end

  describe 'proxy connection' do
    let(:proxy_url) { 'http://localhost:8080' }

    it 'configures HTTPX to use a proxy' do
      client = test_client('test-token', proxy: proxy_url)

      begin
        request = client.send(:connection).build_request(
          'GET',
          "/projects/#{project_id}"
        )

        expect(request.options.proxy.uri.to_s).to eq(proxy_url)
      ensure
        client.close
      end
    end

    it 'performs a request with the proxy plugin enabled' do
      stub_vantage_request(
        method: :get,
        path: "/projects/#{project_id}",
        fixture: 'connection/project.json'
      )

      client = test_client('test-token', proxy: proxy_url)

      begin
        project = client.project(project_id)

        expect(project).to be_a(LokaliseApiNext::Models::Project)
        expect(project.name).to eq('Test project')
      ensure
        client.close
      end
    end
  end
end

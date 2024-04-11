require "rails_helper"

RSpec.describe 'a dummy application', type: :request do
  before do
    allow($stdout).to receive(:write)
  end

  it 'logs basic request details' do
    travel_to(Time.utc(2024, 2, 15, 16, 52, 51.163r), with_usec: true) do
      get '/'

      expect($stdout).to have_received(:write).with("2024-02-15T16:52:51.163Z INFO request.started action=ApplicationController#index ip=127.0.0.1 method=GET format=html params.controller=application params.action=index url=http://www.example.com/\n")
                                              .with(/2024-02-15T16:52:51\.163Z INFO request.processed action=ApplicationController#index ip=127\.0\.0\.1 method=GET format=html params.controller=application params.action=index url=http:\/\/www\.example\.com\/ status=200 duration=\d+\.\d+ db=\d+\.\d+ view=\d+\.\d+\n/)
    end
  end

  it 'logs basic request params' do
    travel_to(Time.utc(2024, 2, 15, 16, 52, 51.163r), with_usec: true) do
      get '/?foo=bar'

      expect($stdout).to have_received(:write).with("2024-02-15T16:52:51.163Z INFO request.started action=ApplicationController#index ip=127.0.0.1 method=GET format=html params.foo=bar params.controller=application params.action=index url=http://www.example.com/?foo=bar\n")
                                              .with(/2024-02-15T16:52:51\.163Z INFO request.processed action=ApplicationController#index ip=127\.0\.0\.1 method=GET format=html params.foo=bar params.controller=application params.action=index url=http:\/\/www\.example\.com\/\?foo= status=200 duration=\d+\.\d+ db=\d+\.\d+ view=\d+\.\d+\n/)
    end
  end
end

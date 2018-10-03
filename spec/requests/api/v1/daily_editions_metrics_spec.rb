RSpec.describe '/api/v1/metrics/', type: :request do
  before { create(:user) }

  let!(:base_path) { '/base_path' }
  let(:warehouse_item_id) { '35058ac0-fb70-4220-81dc-c8b14bededdc' }

  before do
    edition = create :edition, base_path: base_path, date: '2018-01-13', warehouse_item_id: warehouse_item_id, facts: {
                       pdf_count: 30, doc_count: 30, readability: 123
                     }
    create :metric, edition: edition, date: '2018-01-13'
    new_edition = create :edition, replaces: edition, base_path: base_path, date: '2018-01-14', facts: {
                           pdf_count: 20, doc_count: 20, readability: 5
                     }
    create :metric, edition: new_edition, date: '2018-01-14'
    create :metric, edition: new_edition, date: '2018-01-15'
  end

  it 'returns the `number of pdfs` between two dates' do
    get "/api/v1/metrics/#{base_path}/time-series", params: { from: '2018-01-13', to: '2018-01-15', metrics: %w[pdf_count] }
    json = JSON.parse(response.body)
    expect(json.deep_symbolize_keys).to eq(api_reponse('pdf_count'))
  end

  it 'returns the `number of word documents` between two dates' do
    get "/api/v1/metrics/#{base_path}/time-series", params: { from: '2018-01-13', to: '2018-01-15', metrics: %w[doc_count] }

    json = JSON.parse(response.body)
    expect(json.deep_symbolize_keys).to eq(api_reponse('doc_count'))
  end

  it 'returns the `readability score` between two dates' do
    get "/api/v1/metrics/#{base_path}/time-series", params: { from: '2018-01-13', to: '2018-01-15', metrics: %w[readability] }

    json = JSON.parse(response.body)
    expect(json.deep_symbolize_keys).to eq(
      readability: [
        { date: '2018-01-13', value: 123 },
        { date: '2018-01-14', value: 5 },
        { date: '2018-01-15', value: 5 },
      ]
    )
  end

  def api_reponse(metric_name)
    {
      metric_name.to_sym => [
        { date: '2018-01-13', value: 30 },
        { date: '2018-01-14', value: 20 },
        { date: '2018-01-15', value: 20 },
      ]
    }
  end
end

require 'gds-api-adapters'
require 'traceable'

RSpec.describe Etl::GA::ViewsAndNavigationProcessor do
  subject { described_class }

  let!(:item1) { create :dimensions_item, base_path: '/path1', latest: true }
  let!(:item2) { create :dimensions_item, base_path: '/path2', latest: true }

  let(:date) { Date.new(2018, 2, 20) }


  context 'When the base_path matches the GA path' do
    before { allow(Etl::GA::ViewsAndNavigationService).to receive(:find_in_batches).and_yield(ga_response) }
    it 'update the facts with the GA metrics' do
      edition1 = create :edition, base_path: '/path1', date: '2018-02-20'
      edition2 = create :edition, base_path: '/path2', date: '2018-02-20'
      fact1 = create :metric, edition: edition1, date: '2018-02-20'
      fact2 = create :metric, edition: edition2, date: '2018-02-20'

      described_class.process(date: date)

      expect(fact1.reload).to have_attributes(pviews: 1, upviews: 1, entrances: 10, exits: 5, bounce_rate: 50, avg_page_time: 60, bounces: 31, page_time: 20)
      expect(fact2.reload).to have_attributes(pviews: 2, upviews: 2, entrances: 20, exits: 10, bounce_rate: 100, avg_page_time: 30, bounces: 50, page_time: 23)
    end

    it 'does not update metrics for other days' do
      edition = create :edition, date: '2018-02-20', base_path: '/path1'
      fact1 = create :metric, edition: edition, date: '2018-02-20', pviews: 20, upviews: 10

      day_before = date - 1
      described_class.process(date: day_before)

      expect(fact1.reload).to have_attributes(pviews: 20, upviews: 10)
    end

    it 'does not update metrics for other items' do
      edition = create :edition, base_path: '/non-matching-path', date: '2018-02-20'
      fact = create :metric, edition: edition, date: '2018-02-20', pviews: 99, upviews: 90

      described_class.process(date: date)

      expect(fact.reload).to have_attributes(pviews: 99, upviews: 90)
    end

    it "deletes events after updating facts metrics" do
      create(:ga_event, :with_user_feedback, date: date - 1, page_path: '/path1')

      described_class.process(date: date)

      expect(Events::GA.count).to eq(0)
    end

    context 'when there are events from other days' do
      before do
        create(:ga_event, :with_views, date: date - 1, page_path: '/path1')
        create(:ga_event, :with_views, date: date - 2, page_path: '/path1')
      end

      it 'only updates metrics for the current day' do
        edition = create :edition, date: '2018-02-20', base_path: '/path1'
        fact1 = create :metric, edition: edition, date: '2018-02-20'

        described_class.process(date: date)

        expect(fact1.reload).to have_attributes(pviews: 1, upviews: 1)
      end
    end
  end

  private

  def ga_response
    [
      {
        'page_path' => '/path1',
        'pviews' => 1,
        'upviews' => 1,
        'date' => '2018-02-20',
        'process_name' => 'views',
        'entrances' => 10,
        'exits' => 5,
        'bounce_rate' => 50,
        'avg_page_time' => 60,
        'bounces' => 31,
        'page_time' => 20,
      },
      {
        'page_path' => '/path2',
        'pviews' => 2,
        'upviews' => 2,
        'date' => '2018-02-20',
        'process_name' => 'views',
        'entrances' => 20,
        'exits' => 10,
        'bounce_rate' => 100,
        'avg_page_time' => 30,
        'bounces' => 50,
        'page_time' => 23,
      },
    ]
  end

  def ga_response_with_govuk_prefix
    [
      {
        'page_path' => '/https://www.gov.uk/path1',
        'pviews' => 1,
        'upviews' => 1,
        'date' => '2018-02-20',
        'process_name' => 'views',
        'entrances' => 10,
        'exits' => 5,
        'bounce_rate' => 50,
        'avg_page_time' => 60,
        'bounces' => 66,
        'page_time' => 86,
      },
      {
        'page_path' => '/path2',
        'pviews' => 2,
        'upviews' => 2,
        'date' => '2018-02-20',
        'process_name' => 'views',
        'entrances' => 20,
        'exits' => 10,
        'bounce_rate' => 100,
        'avg_page_time' => 30,
        'bounces' => 15,
        'page_time' => 63,
      },
    ]
  end
end

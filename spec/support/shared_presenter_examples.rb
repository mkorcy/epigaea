shared_examples 'a Tufts presenter' do
  subject { described_class.new(double, double) }
  let(:solr_document) { SolrDocument.new(attributes) }
  let(:request) { double }
  let(:user_key) { 'a_user_key' }

  let(:attributes) do
    { "id" => '888888',
      "title_tesim" => ['foo', 'bar'],
      "human_readable_type_tesim" => ["Generic Work"],
      "has_model_ssim" => ["GenericWork"],
      "date_created_tesim" => ['an unformatted date'],
      "depositor_tesim" => user_key }
  end
  let(:ability) { nil }
  let(:presenter) { described_class.new(solr_document, ability, request) }

  describe "with custom attributes that are delegated to Solr and" do
    it { is_expected.to delegate_method(:geographic_name).to(:solr_document) }
    it { is_expected.to delegate_method(:displays_in).to(:solr_document) }
    it { is_expected.to delegate_method(:alternative_title).to(:solr_document) }
    it { is_expected.to delegate_method(:abstract).to(:solr_document) }
    it { is_expected.to delegate_method(:table_of_contents).to(:solr_document) }
    it { is_expected.to delegate_method(:primary_date).to(:solr_document) }
    it { is_expected.to delegate_method(:date_accepted).to(:solr_document) }
    it { is_expected.to delegate_method(:date_available).to(:solr_document) }
    it { is_expected.to delegate_method(:date_copyrighted).to(:solr_document) }
    it { is_expected.to delegate_method(:date_issued).to(:solr_document) }
  end

  describe "with admin attributes that are delegated to Solr" do
    it { is_expected.to delegate_method(:steward).to(:solr_document) }
    it { is_expected.to delegate_method(:created_by).to(:solr_document) }
    it { is_expected.to delegate_method(:internal_note).to(:solr_document) }
    it { is_expected.to delegate_method(:audience).to(:solr_document) }
    it { is_expected.to delegate_method(:end_date).to(:solr_document) }
    it { is_expected.to delegate_method(:accrual_policy).to(:solr_document) }
    it { is_expected.to delegate_method(:license).to(:solr_document) }
  end
end
require 'rails_helper'

RSpec.describe XmlImport, type: :model do
  subject(:import) { FactoryGirl.build(:xml_import) }

  # `it_behaves_like 'a batchable'` tests are pending due to oddities in
  # #enqueue!'s behavior. We need to loosen `batchable` expectations by
  # reworking the tests.

  describe '#records' do
    it 'returns ImportRecords' do
      expect(import.records)
        .to contain_exactly(an_instance_of(Tufts::ImportRecord),
                            an_instance_of(Tufts::ImportRecord))
    end

    it 'has the correct records' do
      expect(import.records.map(&:file)).to contain_exactly('pdf-sample.pdf', '2.pdf')
    end
  end

  describe '#metadata_file' do
    subject(:import)  { FactoryGirl.build(:xml_import, metadata_file: nil) }
    let(:file)        { file_fixture('mira_xml.xml') }

    it 'is an uploader' do
      expect { import.metadata_file = File.open(file) }
        .to change { import.metadata_file }
        .to(an_instance_of(Tufts::MetadataFileUploader))
    end
  end

  describe '#uploaded_file_ids' do
    let(:ids)    { ['1', '2'] }
    let(:upload) { FactoryGirl.create(:hyrax_uploaded_file) }

    it 'sets uploaded file ids' do
      expect { import.uploaded_file_ids.concat(ids) }
        .to change { import.uploaded_file_ids }
        .to contain_exactly(*ids)
    end

    it 'validates existence of file ids' do
      import.uploaded_file_ids = [upload.id]

      expect { import.uploaded_file_ids.concat(ids) }
        .to change { import.valid? }
        .from(true).to(false)
    end
  end

  describe '#uploaded_files' do
    subject(:import) do
      FactoryGirl.create(:xml_import, uploaded_file_ids: files.map(&:id))
    end

    let(:files) { FactoryGirl.create_list(:hyrax_uploaded_file, 3) }

    it 'has the correct files' do
      expect(import.uploaded_files).to contain_exactly(*files)
    end

    context 'when empty' do
      subject(:import) do
        FactoryGirl.create(:xml_import, uploaded_file_ids: [])
      end

      it 'is empty' do
        expect(import.uploaded_files).to be_empty
      end
    end

    context 'with false file ids' do
      before { import.uploaded_file_ids.concat(['false_id']) }

      it 'raises an error' do
        expect { import.uploaded_files }
          .to raise_error ActiveRecord::RecordNotFound
      end
    end
  end

  describe '#enqueue!' do
    subject(:import) do
      FactoryGirl.create(:xml_import, uploaded_file_ids: [file.id])
    end

    let(:file) { FactoryGirl.create(:hyrax_uploaded_file) }

    before { ActiveJob::Base.queue_adapter = :test }

    it 'enqueues the correct job type' do
      expect { import.enqueue! }
        .to enqueue_job(ImportJob)
        .with(import, file)
        .on_queue('batch')
        .once
    end

    it 'does not enqueue jobs for records with no files' do
      expect { import.enqueue! }
        .not_to enqueue_job(ImportJob)
        .with(import, import.records.to_a.last.file)
    end

    context 'when no files have been uploaded' do
      subject(:import) do
        FactoryGirl.create(:xml_import, uploaded_file_ids: [])
      end

      it 'gives an empty result' do
        expect(import.enqueue!).to be_empty
      end

      it 'does not enqueue jobs' do
        expect { import.enqueue! }.not_to enqueue_job(ImportJob)
      end
    end
  end
end

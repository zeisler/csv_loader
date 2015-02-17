require 'rspec'
require 'csv_loader.rb'
require 'support/report_type_mock.rb'

def path(relative)
  File.join(File.dirname(__FILE__), relative)
end

RSpec.describe CsvLoader do
  after(:each) do
    ActiveMocker::LoadedMocks.clear_all
  end

  describe '::load' do

    describe 'options' do

      describe 'model:' do
        it 'take a csv file and import it into a model' do
          CsvLoader.load(path('support/report_types.csv'), model: ReportTypeMock)
          expect(ReportTypeMock.count).to eq(12)
        end
      end

      describe 'destroy_all:' do
        it 'has optional argument to destroy all from model' do
          first_row = ReportTypeMock.first
          CsvLoader.load(path('support/report_types.csv'), model: ReportTypeMock, destroy_all: true)
          expect(ReportTypeMock.count).to eq(12)
          expect(first_row).not_to eq(ReportTypeMock.first.attributes)
        end
      end

      describe 'where: {condition}' do
        it 'takes a hash condition that will only load csv row that meet it' do
          CsvLoader.load(path('support/report_types.csv'), model: ReportTypeMock, where: { name: 'My Report 3' })
          expect(ReportTypeMock.count).to eq 1
          expect(ReportTypeMock.first.attributes).to eq({ "id" => 4, "name" => "My Report 3", "report_family_id" => 1 })
        end

        it 'can take more than one condition' do
          CsvLoader.load(path('support/report_types.csv'), model: ReportTypeMock, where: { name: 'My Report 3', report_family_id: 1 })
          expect(ReportTypeMock.count).to eq 1
          expect(ReportTypeMock.first.attributes).to eq({ "id" => 4, "name" => "My Report 3", "report_family_id" => 1 })
        end

        it 'will return more than one result' do
          CsvLoader.load(path('support/report_types.csv'), model: ReportTypeMock, where: { report_family_id: 2 })
          expect(ReportTypeMock.count).to eq 5
        end

        it 'will take a range of numbers' do
          CsvLoader.load(path('support/report_types.csv'), model: ReportTypeMock, where: { report_family_id: (1..2) })
          expect(ReportTypeMock.count).to eq 12
          expect(ReportTypeMock.all.map(&:report_family_id)).to eq [1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 2, 2]
        end

        it 'will take a regex' do
          CsvLoader.load(path('support/report_types.csv'), model: ReportTypeMock, where: { name: /Report 7/ })
          expect(ReportTypeMock.count).to eq 1
          expect(ReportTypeMock.all.map(&:attributes)).to eq([{ "id" => 11, "name" => "My Report 7", "report_family_id" => 2 }])
        end
      end

      describe 'find' do
        it 'takes an array of ids' do
          CsvLoader.load(path('support/report_types.csv'), model: ReportTypeMock, find: [1, 2, 3])
          expect(ReportTypeMock.all.map(&:id)).to eq [1, 2, 3]
        end

        it 'takes one id' do
          CsvLoader::Each.load(path('support/report_types.csv'), model: ReportTypeMock, find: 1)
          expect(ReportTypeMock.all.map(&:id)).to eq [1]
        end

        it 'will raise an error if not found' do
          expect { CsvLoader.load(path('support/report_types.csv'), model: ReportTypeMock, find: 200) }.to raise_error(CsvLoader::IdsNotFound)
        end

        it 'will not raise an error if not found' do
          expect { CsvLoader.load(path('support/report_types.csv'), model: ReportTypeMock, find: 200, error_if_no_records_found: false) }.not_to raise_error
        end
      end

      describe 'limit' do

        it 'it will only load record until limit reached' do
          CsvLoader.load(path('support/report_types.csv'), model: ReportTypeMock, limit: 3)
          expect(ReportTypeMock.all.count).to eq 3
        end

      end

      describe 'skip_if_exists' do
        it 'skip if id already exists' do
          temp_file = Tempfile.new('temp'+Time.now.to_s)
          temp_file.write <<-CSV.strip_heredoc
          id,name,report_family_id
          1,DC Benchmarking Fees and Services,1
          2,DC Benchmarking Fees (for clients only),1
          CSV
          temp_file.close
          ReportTypeMock.create(id: 1)
          CsvLoader.load(temp_file.path, model: ReportTypeMock, skip_if_exists: :id)
          expect(ReportTypeMock.count).to eq 2
          expect(ReportTypeMock.all.map(&:id)).to eq [1, 2]
          expect(ReportTypeMock.first.name).to eq nil
        end

        it 'skip if id and name already exists' do
          temp_file = Tempfile.new('temp'+Time.now.to_s)
          temp_file.write <<-CSV.strip_heredoc
          id,name,report_family_id
          1,DC Benchmarking Fees and Services,1
          2,DC Benchmarking Fees (for clients only),1
          CSV
          temp_file.close
          ReportTypeMock.create(id: 1, name: 'DC Benchmarking Fees and Services')
          CsvLoader.load(temp_file.path, model: ReportTypeMock, skip_if_exists: [:id, :name])
          expect(ReportTypeMock.count).to eq 2
          expect(ReportTypeMock.all.map(&:id)).to eq [1, 2]
          expect(ReportTypeMock.first.name).to eq 'DC Benchmarking Fees and Services'
        end

        it 'skip if id or name already exists' do
          temp_file = Tempfile.new('temp'+Time.now.to_s)
          temp_file.write <<-CSV.strip_heredoc
          id,name,report_family_id
          3,DC Benchmarking Fees and Services,1
          2,DC Benchmarking Fees (for clients only),1
          CSV
          temp_file.close
          ReportTypeMock.create(id: 1, name: 'DC Benchmarking Fees and Services')
          ReportTypeMock.create(id: 2)
          CsvLoader.load(temp_file.path, model: ReportTypeMock, skip_if_exists_any: [:id, :name])
          expect(ReportTypeMock.count).to eq 2
          expect(ReportTypeMock.all.map(&:id)).to eq [1, 2]
          expect(ReportTypeMock.last.name).to eq nil
        end
      end
    end

    describe 'case where csv has \N as value' do
      it {
        CsvLoader.load(path('support/report_types_with_slash_n.csv'),
                       model: ReportTypeMock)
        expect(ReportTypeMock.first.name).to eq nil
      }
    end

    describe 'freeze' do
      it 'will call freeze on instance after create so that it cannot be modified' do
        CsvLoader.load(path('support/report_types.csv'), model: ReportTypeMock, find: 1, freeze: true)
        expect { ReportTypeMock.first.name = 'New Name' }.to raise_error(RuntimeError, /can't modify frozen/)
      end
    end
  end
end

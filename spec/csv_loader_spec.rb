require 'rspec'
require 'csv_loader.rb'
require 'support/report_type_mock.rb'

def path(relative)
  File.join(File.dirname(__FILE__), relative)
end

RSpec.describe CsvLoader, active_mocker: true do

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

      describe 'limit:' do

        it 'limit the amount of records loader' do
          CsvLoader.load(path('support/report_types.csv'), model: ReportTypeMock, limit: 5)
          expect(ReportTypeMock.count).to eq(5)
        end

        it 'it can take a range of lines' do
          CsvLoader.load(path('support/report_types.csv'), model: ReportTypeMock, limit: (3..5))
          expect(ReportTypeMock.all.map(&:id)).to eq([3, 4, 5])
        end

      end

      describe 'where: {condition}' do

        it 'takes a hash condition that will only load csv row that meet it' do
          CsvLoader.load(path('support/report_types.csv'), model: ReportTypeMock, where: {name: 'My Report 3'})
          expect(ReportTypeMock.count).to eq 1
          expect(ReportTypeMock.first.attributes).to eq({"id" => 4, "name" => "My Report 3", "report_family_id" => 1})
        end

        it 'can take more than one condition' do
          CsvLoader.load(path('support/report_types.csv'), model: ReportTypeMock, where: {name: 'My Report 3', report_family_id: 1})
          expect(ReportTypeMock.count).to eq 1
          expect(ReportTypeMock.first.attributes).to eq({"id" => 4, "name" => "My Report 3", "report_family_id" => 1})
        end

        it 'will return more than one result' do
          CsvLoader.load(path('support/report_types.csv'), model: ReportTypeMock, where: {report_family_id: 2})
          expect(ReportTypeMock.count).to eq 5
        end

      end

      describe 'find' do

        it 'takes an array of ids' do
          CsvLoader.load(path('support/report_types.csv'), model: ReportTypeMock, find: [1, 2, 3])
          expect(ReportTypeMock.all.map(&:id)).to eq [1, 2, 3]
        end

        it 'takes one id' do
          CsvLoader.load(path('support/report_types.csv'), model: ReportTypeMock, find: 1)
          expect(ReportTypeMock.all.map(&:id)).to eq [1]
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

  end

end
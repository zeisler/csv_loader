require 'csv'
require 'csv_loader/version'
require 'csv_loader/load'

module CsvLoader

  def self.load(file_path, options = {})
    Load.new(file_path, options)
  end

end

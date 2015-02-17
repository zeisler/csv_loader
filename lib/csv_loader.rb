require 'csv'
require 'csv_loader/version'
require 'csv_loader/helper'
require 'csv_loader/abstract'
require 'csv_loader/each'
require 'active_support/deprecation'

module CsvLoader

  def self.load(file_path, options = {})
    Each.new(file_path, options)
  end

  class IdsNotFound < Exception
  end

end

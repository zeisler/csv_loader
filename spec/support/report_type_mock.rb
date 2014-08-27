require 'active_mocker/mock'

class ReportTypeMock < ActiveMocker::Mock::Base

  class << self

    def attributes
      @attributes ||= HashWithIndifferentAccess.new({"id" => nil, "name" => nil, "report_family_id" => nil})
    end

    def types
      @types ||= ActiveMocker::Mock::HashProcess.new({id: Fixnum, name: String, report_family_id: Fixnum}, method(:build_type))
    end

    def associations
      @associations ||= {}
    end

    def mocked_class
      'ReportType'
    end

    private :mocked_class

    def attribute_names
      @attribute_names ||= ["id", "name", "report_family_id"]
    end

    def primary_key
      "id"
    end

  end

  ##################################
  #   Attributes getter/setters    #
  ##################################

  def id
    read_attribute(:id)
  end

  def id=(val)
    write_attribute(:id, val)
  end

  def name
    read_attribute(:name)
  end

  def name=(val)
    write_attribute(:name, val)
  end

  def report_family_id
    read_attribute(:report_family_id)
  end

  def report_family_id=(val)
    write_attribute(:report_family_id, val)
  end

  ##################################
  #         Associations           #
  ##################################


  module Scopes

  end

  extend Scopes

  class ScopeRelation < ActiveMocker::Mock::Association
    include ReportTypeMock::Scopes
  end

  private

  def self.new_relation(collection)
    ReportTypeMock::ScopeRelation.new(collection)
  end

  public

  ##################################
  #        Model Methods           #
  ##################################


  private

  def self.reload
    load __FILE__
  end

end
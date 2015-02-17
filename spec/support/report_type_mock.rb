require 'active_mocker/mock'

class ReportTypeMock < ActiveMocker::Mock::Base
  created_with('1.7.3')

  class << self

    def attributes
      @attributes ||= HashWithIndifferentAccess.new({ "id" => nil, "name" => nil, "report_family_id" => nil }).merge(super)
    end

    def types
      @types ||= ActiveMocker::Mock::HashProcess.new({ id: Fixnum, name: String, report_family_id: Fixnum }, method(:build_type)).merge(super)
    end

    def associations
      @associations ||= {}.merge(super)
    end

    def associations_by_class
      @associations_by_class ||= {}.merge(super)
    end

    def mocked_class
      "ReportType"
    end

    private :mocked_class

    def attribute_names
      @attribute_names ||= ["id", "name", "report_family_id"] | super
    end

    def primary_key
      "id"
    end

    def abstract_class?
      false
    end

    def table_name
      "report_types" || super
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
    include ActiveMocker::Mock::Base::Scopes

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


end
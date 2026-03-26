class SampleClientProfile
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :client_code, :string
  attribute :client_name, :string
  attribute :corporation_name, :string
  attribute :corporation_code, :string
  attribute :business_number, :string
  attribute :client_group, :string
  attribute :client_type, :string
  attribute :client_category, :string
  attribute :country_code, :string
  attribute :parent_client_name, :string
  attribute :parent_client_code, :string
  attribute :representative_name, :string
  attribute :representative_business_number, :string
  attribute :postal_address_name, :string
  attribute :postal_code, :string
  attribute :address_line1, :string
  attribute :address_line2, :string
  attribute :effective_from, :date
  attribute :effective_to, :date
  attribute :active, :string

  validates :client_code, :client_name, :corporation_code, :business_number, :client_group,
            :client_type, :country_code, :effective_from, :active, presence: true

  def self.model_name
    ActiveModel::Name.new(self, nil, 'Client')
  end

  def persisted?
    client_code.present?
  end
end

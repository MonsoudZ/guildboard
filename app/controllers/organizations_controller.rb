class OrganizationsController < ApplicationController
  before_action :set_organization, only: :show
  before_action :authorize_membership!, only: :show

  def index
    @organizations = current_user.organizations.includes(:projects).order(:name)
  end

  def show
    @projects = @organization.projects.order(:name)
    membership = current_user.memberships.find_by(organization: @organization)
    @can_invite_members = membership&.manager? || membership&.owner?
    @activity_events = @organization.activity_events.includes(:actor, :subject).recent.limit(20)
  end

  def new
    @organization = Organization.new
  end

  def create
    @organization = Organization.new(organization_params)

    Organization.transaction do
      @organization.save!
      @organization.memberships.create!(user: current_user, role: :owner)
    end

    redirect_to organization_path(@organization), notice: "Organization created."
  rescue ActiveRecord::RecordInvalid
    render :new, status: :unprocessable_entity
  end

  private

  def set_organization
    @organization = Organization.find(params[:id])
  end

  def organization_params
    params.expect(organization: [ :name, :slug ])
  end

  def authorize_membership!
    authorize_policy!(@organization, :view, fallback: organizations_path)
  end
end

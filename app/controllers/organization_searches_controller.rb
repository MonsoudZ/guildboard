class OrganizationSearchesController < ApplicationController
  before_action :set_organization
  before_action :authorize_membership!

  def show
    result = OrganizationSearchQuery.call(
      organization: @organization,
      query: params[:q],
      page: params[:page]
    )
    @query = result.query
    @page = result.page
    @projects = result.projects
    @tasks = result.tasks
    @more_projects = result.more_projects
    @more_tasks = result.more_tasks
  end

  private

  def set_organization
    @organization = Organization.find(params[:organization_id])
  end

  def authorize_membership!
    authorize_policy!(@organization, :search, fallback: organizations_path)
  end
end

class Role::Panel::RolesController < Role::Panel::BaseController
  before_action :set_role, only: [
    :show, :overview, :edit, :update, :destroy,
    :namespaces, :governs, :rules,
    :business_on, :business_off, :namespace_on, :namespace_off, :govern_on, :govern_off, :rule_on, :rule_off
  ]

  def index
    @roles = Role.order(created_at: :asc)
  end

  def new
    @role = Role.new
  end

  def create
    @role = Role.new role_params

    unless @role.save
      render :new, locals: { model: @role }, status: :unprocessable_entity
    end
  end

  def show
    q_params = {}
    q_params.merge! params.permit(:govern_taxon_id)

    @governs = Govern.includes(:rules).default_where(q_params)
    @busynesses = Busyness.all
  end

  def namespaces
    @busyness = Busyness.find_by identifier: params[:business_identifier]
    identifiers = Govern.unscope(:order).select(:namespace_identifier).where(business_identifier: params[:business_identifier]).distinct.pluck(:namespace_identifier)
    @name_spaces = NameSpace.where(identifier: identifiers)
  end

  def governs
    q_params = {}
    q_params.merge! params.permit(:business_identifier, :namespace_identifier)

    @governs = Govern.default_where(q_params)
  end

  def rules
    q_params = {}
    q_params.merge! params.permit(:controller_identifier)

    @rules = Rule.default_where(q_params)
  end

  def overview
    @taxon_ids = @role.governs.unscope(:order).uniq
  end

  def edit
  end

  def business_on
    busyness = Busyness.find_by identifier: params[:business_identifier]
    @role.role_hash.merge! busyness.role_hash
    @role.save
  end

  def business_off
    @role.role_hash.delete params[:business_identifier]
    @role.save
  end

  def namespace_on
    @name_space = NameSpace.find_by identifier: params[:namespace_identifier]
    @role.role_hash.deep_merge!(params[:business_identifier] => {
      params[:namespace_identifier] => @name_space.role_hash(params[:business_identifier])
    })
    @role.save
  end

  def namespace_off
    @name_space = NameSpace.find_by identifier: params[:namespace_identifier]
    @role.role_hash.fetch(params[:business_identifier], {}).delete(params[:namespace_identifier])
    @role.save
  end

  def govern_on
    q_params = {}
    q_params.merge! params.permit(:business_identifier, :namespace_identifier, :controller_name)

    @govern = Govern.find_by(q_params)
    @role.role_hash.deep_merge!(params[:business_identifier] => {
      params[:namespace_identifier] => {
        params[:controller_name] => @govern.role_hash
      }
    })
    @role.save
  end

  def govern_off
    q_params = {}
    q_params.merge! params.permit(:business_identifier, :namespace_identifier, :controller_name)

    @govern = Govern.find_by(q_params)
    @role.role_hash.fetch(params[:business_identifier], {}).fetch(params[:namespace_identifier], {}).delete(params[:controller_name])
    @role.save
  end

  def rule_on
    @rule = Rule.find_by controller_identifier: params[:controller_identifier], action_name: params[:action_name]
    @role.role_hash.deep_merge!(@rule.business_identifier => {
      @rule.namespace_identifier => {
        params[:controller_identifier] => {
          params[:action_name] => true
        }
      }
    })
    @role.save
  end

  def rule_off
    @rule = Rule.find_by controller_identifier: params[:controller_identifier], action_name: params[:action_name]
    @role.role_hash.fetch(@rule.business_identifier, {}).fetch(@rule.namespace_identifier, {}).fetch(params[:controller_identifier], {}).delete(params[:action_name])
    @role.save
  end

  def update
    @role.assign_attributes role_params

    unless @role.save
      render :edit, locals: { model: @role }, status: :unprocessable_entity
    end
  end

  def destroy
    @role.destroy
  end

  private
  def role_params
    p = params.fetch(:role, {}).permit(
      :name,
      :code,
      :description,
      :visible,
      :default,
      who_types: []
    )
    p.fetch(:who_types, []).reject!(&:blank?)
    p
  end

  def set_role
    @role = Role.find params[:id]
  end

end

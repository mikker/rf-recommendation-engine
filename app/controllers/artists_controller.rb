class ArtistsController < ApplicationController
  inherit_resources
  actions :index, :show
  respond_to :json
  respond_to :html
  respond_to :xml

  def similar
    @artists = resource.similar_artists.page(params[:page])
    if params[:q]
      @artists = search(@artists, params[:q])
    end
    render :index
  end

  private

  def resource
    @artist ||= end_of_association_chain.includes(:similar_artists).find(params[:id])
  end

  def collection
    return @artists if @artists

    arel = end_of_association_chain.includes(:similar_artists)
    if params[:q]
      arel = search(arel, params[:q])
    elsif params[:ids]
      arel = arel.where("id IN (?)", params[:ids].split(","))
    end
    @artists = arel.paginate(per_page: 20, page: params[:page])
  end

  def search(arel, q)
    arel.where("name LIKE ? OR last_fm_name LIKE ?", "%#{q}%", "%#{q}%")
  end
end

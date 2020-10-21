module PrettyResponse
  def render_response(result, serializer = nil)
    if result.is_a?(ActiveRecord::Base) # eсли результат положителен
      render_item(result, serializer)
    elsif result.is_a?(ActiveModel::Errors)
      render_errors(result, 422)
    elsif result.nil?
      render_forbidden
    else
      render_json({result: result.to_s, attr: result.instance_variables.to_s}, 422)
    end
  end

  def render_errors(errors, code)
    render_json({errors: errors}, code) #render(json: {errors: errors}, status: code)
  end

  def render_forbidden
    render_json({message: 'Something went wrong'}, 500)
  end

  def render_json(json = {}, code = 200)
    render(json: json, status: code)
  end

  def render_item(item, serializer, extra_params={}, include = '', meta = nil)
    serializer = serializer ? serializer : "#{item.class.name}Serializer"
    params = {current_user: current_user, test: 'test'}.merge(extra_params)
    render_json(serializer.classify.safe_constantize.new(item, params: params, include: include, meta: meta),200)
  end
end
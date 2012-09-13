require 'digest/md5'

class TicketResource < Webmachine::Resource

  def encodings_provided
    {"gzip" => :encode_gzip, "identity" => :encode_identity}
  end

  def allowed_methods
    %W[POST]
  end

  def generate_etag
    # TODO: How to include response body as part of this?
    Digest::MD5.hexdigest(Time.now.utc.to_i.to_s)
  end

  def languages_provided
    ["en-us"]
  end

  def content_types_accepted
    [['application/json', :help_me]]
  end

  def help_me
    # PUT to our API
  end
end

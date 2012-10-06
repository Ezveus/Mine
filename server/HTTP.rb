module HTTP
  def self.error404 response, httpInfos
    response.status = 404
    File.new("./ui/webclient/404").read
  end
end

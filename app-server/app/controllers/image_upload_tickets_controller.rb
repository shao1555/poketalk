class ImageUploadTicketsController < ApplicationController
  RESOURCE_URL = 'https://poketalk.s3.amazonaws.com/'
  def new
    resource_uri = URI.parse(RESOURCE_URL)
    file_name = "images/#{SecureRandom.hex(8)}"
    resource_uri.path = "/#{file_name}"

    s3 = Aws::S3::Resource.new(region: 'ap-northeast-1')
    obj = s3.bucket('poketalk').object(file_name)
    presigned_url = obj.presigned_url(:put, acl: 'public-read')
    render :show, locals: { presigned_url: presigned_url, resource_url: resource_uri.to_s }
  end
end

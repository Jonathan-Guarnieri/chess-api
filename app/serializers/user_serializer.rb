class UserSerializer
  include JSONAPI::Serializer
  attributes :id, :email, :nickname
end

json.licenses do
  json.array! @licenses, :id, :key, :status, :platform
end
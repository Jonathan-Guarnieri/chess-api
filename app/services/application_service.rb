class ApplicationService
  def call(**args)
    self.new.call(**args)
  end
end

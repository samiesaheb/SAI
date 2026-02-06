require "open3"

class PostClassifierService
  PYTHON_SCRIPT = Rails.root.join("app", "services", "post_classifier.py").to_s

  def self.classify(text)
    result = run_python_classifier(text)
    {
      category: result["category"],
      quality_score: result["quality_score"]
    }
  rescue => e
    Rails.logger.error "PostClassifierService error: #{e.message}"
    { category: "other", quality_score: 0.0 }
  end

  private

  def self.run_python_classifier(text)
    stdout, stderr, status = Open3.capture3("python3", PYTHON_SCRIPT, stdin_data: text)

    unless status.success?
      Rails.logger.error "Python classifier failed: #{stderr}"
      return { "category" => "other", "quality_score" => 0.0 }
    end

    JSON.parse(stdout)
  end
end

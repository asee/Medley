require 'rubygems'
require 'test/unit'
require 'fileutils'
require 'rack/test'
require 'test/rack_test_patch'

require 'combo_handler'
class ComboHandlerTest < Test::Unit::TestCase
  include Rack::Test::Methods
  include FileUtils

  TEST_FILES = Dir.glob(File.join(File.dirname(File.expand_path(__FILE__)),'fixtures') + '/*')

  def app
    ComboHandler
  end
    
  def setup
    TEST_FILES.each do |file|
      ln_s(file, app::ROOT_FILE_PATH)
    end
  end
  
  def teardown
    TEST_FILES.each do |file|
      rm(File.join(app::ROOT_FILE_PATH, File.basename(file)))
    end
  end
  
  def test_home_page
    get '/'
    assert_equal('Give me some info', last_response.body)
  end
  
  def test_should_forbid_file_requests_outside_the_public_app_root
    get '/combo?../some_file.file'
    assert_equal 403, last_response.status
    assert_equal '', last_response.body
  end
  
  def test_should_return_404_if_a_file_is_not_found
    file_paths = TEST_FILES.map{|x| File.basename(x)}
    file_path_thats_not_there = 'some_file_that_is_totally_not_there.file'
    file_paths << file_path_thats_not_there
    get "/combo?#{file_paths.join('&')}"
    assert_equal 404, last_response.status
    assert_equal "#{file_path_thats_not_there} was not found!", last_response.body
  end
    
  def test_should_concatenate_files_in_the_order_they_are_requested
    file_paths = TEST_FILES.map{|x| File.basename(x)}
    concatenated_files = file_paths.map do |path|
      IO.read(File.expand_path(File.join(app::ROOT_FILE_PATH, path)))
    end.join('')
    
    get "/combo?#{file_paths.join('&')}"
    assert_equal 200, last_response.status
    assert_equal concatenated_files, last_response.body
    
    reverse_concatenated_files = file_paths.reverse.map do |path|
      IO.read(File.expand_path(File.join(app::ROOT_FILE_PATH, path)))
    end.join('')
    
    assert_not_equal reverse_concatenated_files, concatenated_files
    assert_not_equal reverse_concatenated_files, last_response.body
  
    get "/combo?#{file_paths.reverse.join('&')}"
    assert_equal 200, last_response.status
    assert_equal reverse_concatenated_files, last_response.body
  end
  
end
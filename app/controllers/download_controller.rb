class DownloadController < ActionController::Base
  include ActionController::Live

  # Default start and limit values
  DEFAULT_START = 0
  BUFFER_SIZE = 4 * 1024 * 1024
  FILE_PATH = '/home/tmp/tmp_file'

  def index
    start = extract_params[:start].to_i || DEFAULT_START
    limit = extract_params[:limit].to_i || 0
    tmp_file = File.open(FILE_PATH, 'rb+')
    raise 'invalid_file' if tmp_file.nil?

    begin

      len = limit
      len = tmp_file.stat.size.to_i if limit == 0
      len = tmp_file.stat.size.to_i if limit > tmp_file.stat.size.to_i
      
      #response.content_type = 'application/octet-stream'
      send_data IO.binread(FILE_PATH, len, start), type: 'application/octet-stream'
      # if len < BUFFER_SIZE
      #   chunk = len
      # else
      #   chunk = BUFFER_SIZE
      # end
      #
      # offset = start
      # while offset < start+len
      #   puts "Reading #{chunk} bytes from offset: #{offset}"
      #   content = IO.binread(FILE_PATH, chunk, offset)
      #   response.stream.write(content)
      #   offset += chunk
      # end

    rescue => e
      Rails.logger.error "Exception while streaming file: #{e} ::: #{e.inspect}"
    ensure
      #response.stream.close
    end
  end

  def file_size
    size = File.open(FILE_PATH, 'rb+').stat.size.to_i
    render inline: "#{size}"
  end

  private

  def extract_params
    params.permit(:start, :limit)
  end
end

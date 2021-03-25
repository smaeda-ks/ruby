require 'irb'

begin
  require 'yamatanooroti'

  class IRB::TestRendering < Yamatanooroti::TestCase
    def setup
      @pwd = Dir.pwd
      suffix = '%010d' % Random.rand(0..65535)
      @tmpdir = File.join(File.expand_path(Dir.tmpdir), "test_irb_#{$$}_#{suffix}")
      begin
        Dir.mkdir(@tmpdir)
      rescue Errno::EEXIST
        FileUtils.rm_rf(@tmpdir)
        Dir.mkdir(@tmpdir)
      end
      @irbrc_backup = ENV['IRBRC']
      @irbrc_file = ENV['IRBRC'] = File.join(@tmpdir, 'temporaty_irbrc')
      File.unlink(@irbrc_file) if File.exist?(@irbrc_file)
    end

    def teardown
      FileUtils.rm_rf(@tmpdir)
      ENV['IRBRC'] = @irbrc_backup
      ENV.delete('RELINE_TEST_PROMPT') if ENV['RELINE_TEST_PROMPT']
    end

    def test_launch
      write_irbrc <<~'LINES'
        puts 'start IRB'
      LINES
      start_terminal(25, 80, %W{ruby -I#{@pwd}/lib -I#{@pwd}/../reline/lib #{@pwd}/exe/irb}, startup_message: 'start IRB')
      write(<<~EOC)
        'Hello, World!'
      EOC
      close
      assert_screen(<<~EOC)
        start IRB
        irb(main):001:0> 'Hello, World!'
        => "Hello, World!"
        irb(main):002:0>
      EOC
    end

    private def write_irbrc(content)
      File.open(@irbrc_file, 'w') do |f|
        f.write content
      end
    end
  end
rescue LoadError, NameError
  # On Ruby repository, this test suit doesn't run because Ruby repo doesn't
  # have the yamatanooroti gem.
end
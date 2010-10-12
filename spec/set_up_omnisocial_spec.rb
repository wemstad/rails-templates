appname = 'set_up_omnisocial'

depends = [:set_up_haml]

def generate_app(appname, template = nil)
  cmd = "rails new #{appname} -s"
  cmd << " -m #{File.join(File.dirname(__FILE__), '..', template+'.rb')}" unless template.nil?
  puts `#{cmd}`
end

describe 'set_up_omnisocial', do
  before(:all) do
    generate_app(appname)
    
    depends.each do |dependency|
      generate_app(appname, dependency.to_s)
    end

    FileUtils.touch(File.join(appname,'config','initializers', "setupomnisocial.rb"))
    generate_app(appname, appname)
  end

  it "adds the omnisocial gem to the Gemfile" do
    gemfile = File.open(File.join(appname,'Gemfile'),'r').read
    gemfile.should match /gem "omnisocial"/
  end
  
  it "installs the gem" do
    gemlockfile = File.open(File.join(appname,'Gemfile.lock'),'r').read
    gemlockfile.should match /omnisocial/
  end
  
  it "generates the omnisocial files" do
    File.exist?(File.join(appname,'public','stylesheets','omnisocial.css')).should be_true
    File.exist?(File.join(appname,'config','initializers','omnisocial.rb')).should be_true
    Dir.glob(File.join(appname,'db','migrate','*create_omnisocial_tables.rb')).empty?.should be_false
  end
  
  after(:all) do
    puts `rm -rf #{appname}`
  end
end

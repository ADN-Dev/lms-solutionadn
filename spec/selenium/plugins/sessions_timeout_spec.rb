require File.expand_path('spec/selenium/common')

describe "Sessions Timeout" do
  include_context "in-process server selenium tests"

  describe "Validations" do 
    context "when you are logged in as an admin" do 
      before do
        user_logged_in
        Account.site_admin.account_users.create!(user: @user)
      end

      it "requires session expiration to be at least 20 minutes" do 
        get "/plugins/sessions"
        if !f("#plugin_setting_disabled").displayed?
          f("#accounts_select option:nth-child(2)").click
          keep_trying_until { f("#plugin_setting_disabled").displayed? }
        end
        f("#plugin_setting_disabled").click
        f('#settings_session_timeout').send_keys('19')
        expect_new_page_load{ f('.save_button').click }
        assert_flash_error_message /There was an error saving the plugin settings/
      end
    end
  end

  it "when sessions timeout is set to .04 minutes it logs the user out after 3 seconds" do
    plugin_setting = PluginSetting.new(:name => "sessions", :settings => {"session_timeout" => ".04"})
    plugin_setting.save!
    user_with_pseudonym({:active_user => true})
    login_as
    expect(f('.user_name').text).to eq @user.primary_pseudonym.unique_id

    sleep 3

    get "/courses"

    assert_flash_warning_message(/You must be logged in to access this page/)
  end
end

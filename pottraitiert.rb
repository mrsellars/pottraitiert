require 'sinatra'
require 'pony'
require 'rack/recaptcha'
use Rack::Recaptcha, :public_key => ENV['RECAPTCHA_PUBLIC_KEY'], :private_key => ENV['RECAPTCHA_PRIVATE_KEY']
#just using recaptcha_valid?
helpers Rack::Recaptcha::Helpers

configure do
  set :public_folder, File.dirname(__FILE__) + '/_site'
end

get '/' do
  redirect '/index.html'
end

get '/kontakt.html' do
  erb :kontakt
end

post '/nachricht'do
 @notice = ''
 @errors = {}
 email = params[:nachricht][:email]
 @errors[:email] = 'Bitte eine richtige Email-Adresse angeben.' if (email.empty? || valid_email?(email).nil?)
 @errors[:text]  = 'Bitte einen Text angeben.' if params[:nachricht][:text].empty?
 @errors[:captcha] = 'Das eingegebene reCAPTCHA war falsch.' unless recaptcha_valid?

 if @errors.empty?
   Pony.mail({:from => params[:nachricht][:email],
     :to => 'tkeller.online@googlemail.com',
     :subject => "Nachricht von pottraitiert.de",
     :body => params[:nachricht][:text],
     :port => '587',
     :via => :smtp,
     :via_options => {
       :address              => 'smtp.sendgrid.net',
       :port                 =>  587,
       :user_name            => ENV['SENDGRID_USERNAME'],
       :password             => ENV['SENDGRID_PASSWORD'],
       :authentication       => :plain,
       :enable_starttls_auto => true
   	}
   })
   @notice = 'Deine Nachricht wurde verschickt :-).'
   params[:nachricht] = {}
 else
   @notice = 'Es ist ein Fehler aufgetreten :-(.'
 end
 erb :kontakt
end

def valid_email? email
  email =~ /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i
end
require 'sinatra'

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
 
 @errors[:name]  = 'Bitte einen Namen angeben.' if params[:nachricht][:name].empty? 
 email = params[:nachricht][:email]
 @errors[:email] = 'Bitte eine richtige Email-Adresse angeben.' if (email.empty? || valid_email?(email).nil?)
 @errors[:text]  = 'Bitte einen Text angeben.' if params[:nachricht][:text].empty?
 
 #require 'ruby-debug'
 #debugger
 
 if @errors.empty?
   @notice = 'Deine Nachricht wurde verschickt :-).'
 else
   @notice = 'Es ist ein Fehler aufgetreten :-(.'
 end
end

def valid_email? email
  email =~ /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i
end
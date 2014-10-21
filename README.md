# Doop Demo
An example doop-rails project which is used as the template for the doopgovuk generator.


## Development

   git clone git@github.com:coder36/doop.git
   cd doop
   git submodule init
   cd ..
   git clone git@github.com:coder36/doop_demo.git
   cd doop_demo
   bundle install
   rails s


## Publishing to Heroku

    touch heroku
    bundle install
    git add .
    git commit -m"Heroku build"
    heroku login     (provide email and password)
    git push heroku


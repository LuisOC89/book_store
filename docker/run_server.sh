#! /bin/sh

python manage.py migrate --no-input
python manage.py collectstatic --no-input

if test $ENV_TYPE = 'local'
then
  
  python manage.py runserver 0.0.0.0:8000
else
  echo 'Running gunicorn for production using gunicorn.conf'
  gunicorn -c docker/gunicorn.conf.py config.wsgi:application
fi

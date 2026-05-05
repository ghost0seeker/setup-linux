if status is-interactive
	starship init fish | source
	alias pmr "python manage.py runserver"
	alias kssh "kitten ssh"
end

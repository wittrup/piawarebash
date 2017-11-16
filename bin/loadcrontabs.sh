# https://stackoverflow.com/questions/7103531/how-to-get-the-part-of-file-after-the-line-that-matches-grep-expression-first/7104422#7104422
sudo cat /var/spool/cron/crontabs/$USER | sed -n -e '/# m h  dom mon dow   command/,$p' > "${HOME}/${USER}crontabs"

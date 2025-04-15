# README

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version

* System dependencies

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...



INICIO DA APLICACAO VAI TER:
user -> front -> mexe uma peca
front -> movimento -> back
back -> validar movimento -> responde pro front se eh valido

DEFINIR COMO SERA A COMUNICACAO ENTRE BACK/FRONT:
- websocket
- como eh os movimentos de peca -> notacao oficial do xadrez



TODO:
1) criar sistema de login
2) ao iniciar um jogo, precisa criar um ID unico de jogo e armazenar ele como current_game para os 2 jogadores logados 
3) [em caso de desconectar um usuario que estava jogando] ao abrir a aplicacao, se em jogo (usuario ao logar tem current_game), redireciona para o jogo e carrega o state atual (jogo que segue)

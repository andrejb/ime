##############################################################################
# MAC0448 - Programação para Redes de Computadores
# 1o. semestre de 2009
# Prof.: Manoel Marcilio Sanches
#
# EP 2 - Servidor de Bolsa de Valores
# André Jucovsky Bianchi - 3682247
##############################################################################


# portas para rodar os testes
STOCKSERVER_PORT = 8080
MSG_SERVER_PORT = 8888


# variaveis de ambiente
JAVA = /usr/bin/java
JAVAC = /usr/bin/javac
JAR = /usr/bin/jar
PKG_NAME = mac448-andre.bianchi-ep1


# regras
all: StockServer.jar RandomClient.class

StockServer.jar: StockServer.java
	$(JAVAC) StockServer.java
	$(JAR) cvfm StockServer.jar manifest.txt *.class

RandomClient.class: RandomClient.java
	$(JAVAC) RandomClient.java

run: all
	$(JAVA) -jar StockServer.jar $(STOCKSERVER_PORT) $(MSG_SERVER_PORT)

test: all
	$(JAVA) RandomClient $(MSG_SERVER_PORT)

edit:
	vim -p *.java Makefile LEIAME.txt

partial-clean:
	rm -f *.class

clean: partial-clean
	rm -f *.jar

pkg: all partial-clean
	mkdir -p $(PKG_NAME)
	cp *.java *.jar LEIAME.txt Makefile $(PKG_NAME)/
	cp Posicao.txt.default $(PKG_NAME)/Posicao.txt
	tar cjf $(PKG_NAME).tar.bz2 $(PKG_NAME)/
	rm -rf $(PKG_NAME)/

.PHONY: all test edit clean pkg partial-clean

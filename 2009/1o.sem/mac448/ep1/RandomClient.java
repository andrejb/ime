/*****************************************************************************
 * MAC0448 - Programação para Redes de Computadores
 * 1o. semestre de 2009
 * Professor: Manoel Marcilio Sanches
 * 
 * EP1 - Servidor HTTP e Servidor de Mensagens
 * André Jucovsky Bianchi - 3682247
 ****************************************************************************/


import java.io.*;
import java.net.*;
import java.util.*;


/*****************************************************************************
 * ExampleClient: um cliente do servidor de mensagens.
 ****************************************************************************/
public class RandomClient {
	private int port;
	
	/*************************************************************************
	 * main: conecta num servidor na porta especificada.
	 ************************************************************************/
	public static void main(String[] args) throws Exception {
		/* mensagem de ajuda */
		if (args.length == 0
				|| args[0].equals("-h")
				|| args[0].equals("--help")) {
			help();
			System.exit(0);
		} else if (args.length > 1) {
			help();
			System.exit(1);  /* erro, precisamos das portas como argumento */
		}
			
		RandomClient client = new RandomClient(Integer.parseInt(args[0]));
		client.run();
	}
	
	
	/*************************************************************************
	 * help: mostra uma mensagem de ajuda.
	 ************************************************************************/
	public static void help() {
		System.out.println("Usage: java RandomClient <msg server port>");
		System.out.println("  msg server port: the port in which to run the message server.");
	}
	
	
	/*************************************************************************
	 * randomClient: construtor.
	 ************************************************************************/
	public RandomClient(int port) {
		this.port = port;
	}
	
	
	/*************************************************************************
	 * run: roda o cliente.
	 ************************************************************************/
	private void run() {
		
		Random r = new Random();
		int stock;
		String action;
		float price;
		int amount;
		
		String stockNames[] = new String[5];
		float stockBuyPrices[] = new float[5];
		float stockSellPrices[] = new float[5];
		
/*		stockNames[0] = "GGBR4";
		stockNames[1] = "ITSA4";
		stockNames[2] = "PETR4";
		stockNames[3] = "USIM5";
		stockNames[4] = "VALE5";*/
		
				
		try {
			while (true) {
				System.out.print("> Connecting to server... ");
				Socket connectionSocket = new Socket("127.0.0.1", port);
				System.out.println("ok.");
				
				/* comunicação com o cliente */
				PrintStream outToServer =
					new PrintStream(connectionSocket.getOutputStream());
				BufferedReader inFromServer =
					new BufferedReader(
						new InputStreamReader(connectionSocket.getInputStream()));
				
				/* recebe os dados do servidor */
				String requestMessageLine = inFromServer.readLine();
				StringTokenizer tokenizedLine =
					new StringTokenizer(requestMessageLine);
				for (int i = 0; i < 5; i++) {
					stockNames[i] = tokenizedLine.nextToken();
					stockBuyPrices[i] = Float.parseFloat(tokenizedLine.nextToken());
					stockSellPrices[i] = Float.parseFloat(tokenizedLine.nextToken());
				}
				/* escolhe uma ação aleatoriamente */
				stock = r.nextInt(5);
				
				/* escolhe se compra ou vende */
				if (r.nextInt(1) == 0)
					action = "C";
				else
					action = "V";

				/* escolhe um valor aleatório para a ação */
				price = (action == "C" ? stockBuyPrices[stock] : stockSellPrices[stock])
					* (float) (1.0 + (r.nextFloat() * 0.02));
				
				/* escolhe uma quantidade para comprar ou vender */
				amount = r.nextInt(300);
				
				/* envia a mensagem para o servidor */
				System.out.print(">> Sending message to server... ");
				outToServer.println(stockNames[stock] + " "
				                               + action + " "
				                               + price + " "
				                               + amount);
				/* aqui, a conexão é fechada automaticamente */
				
				System.out.println("ok.");
				
				/* dorme entre 1 e 20 segundos */
				Thread.sleep(r.nextInt(20) * 1000);
			}
		} catch (Exception e) {
			System.err.println("Error in MessageServer.run(): "
					+ e.getMessage());	
		}
	}
}

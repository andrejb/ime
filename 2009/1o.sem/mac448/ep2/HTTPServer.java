/*****************************************************************************
 * MAC0448 - Programação para Redes de Computadores
 * 1o. semestre de 2009
 * Professor: Manoel Marcilio Sanches
 * 
 * EP 2 - Servidor de Bolsa de Valores
 * André Jucovsky Bianchi - 3682247
 ****************************************************************************/


import java.io.*;
import java.net.*;
import java.util.*;


/*****************************************************************************
 * StockServer: implementa um servidor de Bolsa de Valores básico, referente
 *              ao EP2 de MAC448. Também contém um servidor de mensagens e um
 *              atualizador de arquivos que mantém os dados persistentes no
 *              HD.
 ****************************************************************************/
public class StockServer {

	
	/*************************************************************************
	 * variáveis de instância
	 ************************************************************************/
	private int httpPort;				/* porta do servidor http */
	private int msgPort;		 		/* porta do servidor de mensagens */
	private String stockFilename;		/* nome do arquivo de dados */
	private String[] stockNames;		/* o nome das ações */
	private float[] stockBuyPrices;		/* preco de compra das acoes */
	private float[] stockSellPrices;	/* preco de venda das acoes */
	private int[] stockTotalAmounts;	/* quantidade total negociada */
	private float[] stockTotalValues;	/* valor total negociado */
	
	
	/*************************************************************************
	 * main: instancia um servidor e o inicia em uma porta designada.
	 ************************************************************************/
	public static void main(String[] args) throws Exception {
		/* mensagem de ajuda */
		if (args.length == 0
				|| args[0].equals("-h")
				|| args[0].equals("--help")) {
			help();
			System.exit(0);
		} else if (args.length < 2 || args.length > 2) {
			help();
			System.exit(1);  /* erro, precisamos das portas como argumento */
		}
			
		StockServer server = new StockServer(Integer.parseInt(args[0]),
										   Integer.parseInt(args[1]),
										   "Posicao.txt");
		server.run();
	}
	
	
	/*************************************************************************
	 * help: mostra uma mensagem de ajuda.
	 ************************************************************************/
	public static void help() {
		System.out.println("Usage: java -jar StockServer.jar <http port> <msg server port>");
		System.out.println("  http port: the port in which to run the Stock server.");
		System.out.println("  msg server port: the port in which to run the message server.");
	}
	
	/*************************************************************************
	 * StockServer: construtor de uma instância do servidor.
	 ************************************************************************/
	public StockServer(int port, int ms_port, String filename) {
		System.out.print("> Initializing server... ");
		this.stockFilename = new String(filename);
		this.httpPort = port;
		this.msgPort = ms_port;
		this.stockNames = new String[5];
		this.stockBuyPrices = new float[5];
		this.stockSellPrices = new float[5];
		this.stockTotalAmounts = new int[5];
		this.stockTotalValues = new float[5];
		System.out.println("ok.");
	}
	
	
	/*************************************************************************
	 * startThreads: inicia as threads de arquivo e mensagens.
	 ************************************************************************/
	private void startThreads() {
		/* Threads */
		System.out.print("> Starting threads... ");
		new Thread(this.new FileUpdater(stockFilename, this, 30000)).start();
		new Thread(this.new MessageServer(msgPort, this)).start();
		System.out.println("ok.");
	}
	
	
	/*************************************************************************
	 * run: Este método contém todo o trabalho do servidor http.
         *
         * Funcionamento desejado:
         *
         *   Leia o arquivo Posicao.txt e guarde nas tabelas(ACAO,VC, VV, QTN, VTN)
         *   Dispare as Threads abaixo;
         *   while (true) {
         *      Espere conexão de cliente;
         *      Dispare a Thread específica deste cliente;
         *   }
         *
         * Teremos que fazer uma nova thread com o seguinte comportamento:
         *
         *   // guarda esse cliente na tabela de clientes conectados e
         *   // pede sua identificação
         *   Guarde cliente
         *   Pede identificação // não precisa fazer consistência
         *   Envie a tabela;
         *   Pede fim;
         *
         * Por fim, o cliente que se conecta deve funcionar assim:
         *
         *   While (true) {
         *        Receba tabela;
         *        Mostre tabela;
         *   }
         *
	 ************************************************************************/
	private void run() {
		System.out.println("> Running server. ");
		/* lê os dados do arquivo */
		retrieveStockInfoFromFile();
		/* inicia as threads */
		startThreads();
		
		/* roda o servidor http */
		try {
			listenStock();
		} catch (Exception e) {
			System.err.println("Error in StockServer.run(): "
					+ e.getMessage());
		}
	}
	
	
	/*************************************************************************
	 * listenStock: aguarda uma conexão de um cliente e responde
         *              adequadamente.
	 ************************************************************************/
	private void listenStock() throws Exception {

		/* cria socket e aguarda conexão */
		ServerSocket listenSocket = new ServerSocket(httpPort);
		  
		while (true) {
			Socket connectionSocket = listenSocket.accept();
			System.out.print(">> Received http connection... ");
	  
			/* comunicação com o cliente */
			BufferedReader inFromClient =
				new BufferedReader(
					new InputStreamReader(connectionSocket.getInputStream()));
			DataOutputStream outToClient =
				new DataOutputStream(connectionSocket.getOutputStream());
		  
			/* lê a requisição do cliente */
			String requestMessageLine = inFromClient.readLine();
			StringTokenizer tokenizedLine =
				new StringTokenizer(requestMessageLine);

			/* escreve a tabela */
			if (tokenizedLine.nextToken().equals("GET")){
				String content = stockInfoStringFormatted();
				StockHeader(outToClient, "text", content.length());
				outToClient.writeBytes(content);
				connectionSocket.close();
			}
			else System.out.println("Bad Request Message");
			System.out.println("ok.");
		}
	}
	
	
	/*************************************************************************
	 * StockHeader: envia cabeçalhos http para o stream de saída indicado.
	 ************************************************************************/
	private void StockHeader(DataOutputStream os,
							String type,
							int length) throws Exception {
		os.writeBytes("Stock/1.0 200 Document Follows\r\n");
		os.writeBytes("Content-Type: " + type + "\r\n");
        os.writeBytes("Content-Length: " + length + "\r\n");
        os.writeBytes("\r\n");
	}
	
	
	/*************************************************************************
	 * retrieveStockInfoFromFile: recupera a informação das ações do arquivo.
	 ************************************************************************/
	private void retrieveStockInfoFromFile() {
		System.out.print("> Retrieving stock info from file... ");
		try {
			FileInputStream fstream = new FileInputStream(stockFilename);
    	    DataInputStream in = new DataInputStream(fstream);
    	    BufferedReader br = new BufferedReader(new InputStreamReader(in));
    	    String strLine;
    	    StringTokenizer tokenizedLine;
    	    int i = 0;
    	    while ((strLine = br.readLine()) != null)   {
    	    	tokenizedLine = new StringTokenizer(strLine);
        	    stockNames[i] = tokenizedLine.nextToken();    	    	
    	    	stockBuyPrices[i] = Float.parseFloat(tokenizedLine.nextToken());
    	    	stockSellPrices[i] = Float.parseFloat(tokenizedLine.nextToken());
    	    	stockTotalAmounts[i] = Integer.parseInt(tokenizedLine.nextToken());
    	    	stockTotalValues[i] = Float.parseFloat(tokenizedLine.nextToken());
    	    	i++;
    	    }
    	    in.close();
		}
		catch (Exception e) {
			System.err.println("Error in retrieveStockInfoFromFile(): "
					+ e.getMessage());
		}
		System.out.println("ok.");
	}
	
	
	/*************************************************************************
	 * stockInfoStringFormatted: devolve uma string com a tabela formatada.
	 ************************************************************************/
	private String stockInfoStringFormatted() {
		String s = new String();
		s  = ".=========================================================================================.\n";
		s += "|       Acao      | Valor de Compra | Valor de Venda  | Qtde Total Neg. | Val. Total Neg. |\n";
		s += "|=========================================================================================|\n";
		for (int i = 0; i < 5; i++) {
			s += "|      " + stockNames[i] + "      ";
			s += "| " + printCol(stockBuyPrices[i], 16);
			s += "| " + printCol(stockSellPrices[i], 16);
			s += "| " + printCol(stockTotalAmounts[i], 16);
			s += "| " + printCol(stockTotalValues[i], 16);
			s += "|\n";
		}
		s += "'========================================================================================='";
		return s;
	}
	
	
	/*************************************************************************
	 * stockInfoString: devolve uma string com a tabela.
	 ************************************************************************/
	public String stockInfoString() {
		String s = new String();
		for (int i = 0; i < 5; i++) {
			s += stockNames[i] + " ";
			s += stockBuyPrices[i] + " ";
			s += stockSellPrices[i] + " ";
			s += stockTotalAmounts[i] + " ";
			s += stockTotalValues[i];
			if (i != 4)
				s += "\n";
		}
		return s;
	}
	
	/*************************************************************************
	 * printCol: Imprime um float f com size espaços à direita.
	 ************************************************************************/
	private static String printCol(float f, int size) {
		Float fl = new Float(f);
		String s = fl.toString();
		int l = s.length();
		for (int i = 0; i < size - l; i++)
			s += " ";
		return s;
	}
	
	
	/************************************************************************
	 * updateStockInfo: Atualiza a tabela de acordo com uma compra ou venda. 
	 ***********************************************************************/
	public void updateStockInfo(String stockName, String action, float price,
								int amount) {
		int i;
		/* encontra a ação pelo nome */
		for (i = 0; i < 5; i++) {
			if (stockNames[i].equals(stockName.trim()))
				break;
		}
		
		/* atualiza os dados */
		if (action.trim().equals("C"))                 /* estamos comprando */
			stockBuyPrices[i] = price;
		if (action.trim().equals("V"))                  /* estamos vendendo */
			stockSellPrices[i] = price;
		stockTotalAmounts[i] += amount;
		stockTotalValues[i] += amount * price;
	}
	
	
	
	
	/*                                 ***                                  */
	/*                             FileUpdater                              */
	/*                                 ***                                  */

	
	/*************************************************************************
	 * FileUpdater: Thread que grava o arquivo periodicamente.
	 ************************************************************************/
	public class FileUpdater implements Runnable {
		
		private String fileName;
		private StockServer server;
		private int sleepTime;
		
		/*********************************************************************
		 * FileUpdater: construtor.
		 ********************************************************************/
		public FileUpdater(String fileName, StockServer server, int sleepTime) {
			this.fileName = fileName;
			this.server = server;
			this.sleepTime = sleepTime;
		}
		
		
		/*********************************************************************
		 * run: grava o arquivo a cada periodo de tempo.
                 *
                 * Funcionamento esperado:
                 *
                 *   // recebe mensagens de operações e atualiza tabelas
                 *   while (true) {
                 *      Espere chegar msg;
                 *      Atualize tabela (ACAO,VC, VV, QTN, VTN);
                 *      Atualize a tela de todos os clientes conectados;
                 *   }
                 *
		 ********************************************************************/
		public void run() {
			while (true) {
				try {
					sleep();
					writeFile();
				} catch (Exception e) {
					System.err.println("Error in FileUpdater.run(): "
							+ e.getMessage());
				}
			}
		}
		
		
		/*********************************************************************
		 * writeFile: grava o arquivo.
		 ********************************************************************/
		private void writeFile() {
			try {
				synchronized (server) {
					FileWriter fstream = new FileWriter(fileName);
					BufferedWriter out = new BufferedWriter(fstream);
					out.write(stockInfoString());
			    	out.close();
				}
			}
			catch (Exception e) {
				System.err.println("Error in FileUpdater.writeFile(): "
						+ e.getMessage());
			}
		}
		
		
		/*********************************************************************
		 * sleep: dorme pelo tempo estabelecido.
		 ********************************************************************/
		private void sleep() throws Exception  {
				Thread.sleep(sleepTime);
		}
	}
	
	
	
	
	/*                                 ***                                  */
	/*                             MessageServer                             */
	/*                                 ***                                  */

	
	/*************************************************************************
	 * MessageServer: recebe mensagens e atualiza a tabela de dados.
	 ************************************************************************/
	public class MessageServer implements Runnable{
		
		
		/*********************************************************************
		 * variáveis de instância
		 ********************************************************************/
		private StockServer server;
		private int port;
		
		
		/*********************************************************************
		 * MessageServer: construtor.
		 ********************************************************************/
		public MessageServer(int port, StockServer server) {
			this.port = port;
			this.server = server;
		}
		
		
		/*********************************************************************
		 * run: roda o servidor de mensagens.
		 ********************************************************************/
		public void run() {
			String info = new String();
			System.out.println("> Running Message Server.");
			try {
				ServerSocket listenSocket = new ServerSocket(port);
				while (true) {
					Socket connectionSocket = listenSocket.accept();
					System.out.print(">> Received message connection... ");
					
					/* comunicação com o cliente */
					BufferedReader inFromClient =
						new BufferedReader(
								new InputStreamReader(connectionSocket.getInputStream()));
					DataOutputStream outToClient =
						new DataOutputStream(connectionSocket.getOutputStream());

					/* gera string de informação para o cliente */
					for (int i = 0; i < 5; i++) {
						info += stockNames[i] + " ";
						info += stockBuyPrices[i] + " ";
						info += stockSellPrices[i] + " ";
					}
					info += "\n";
					outToClient.writeBytes(info);
					
					/* lê a requisição do cliente */
					String requestMessageLine = inFromClient.readLine();
					StringTokenizer tokenizedLine =
						new StringTokenizer(requestMessageLine);
					
					/* atualiza os dados no servidor */
					String stockName, action;
					float price;
					int amount;
					stockName = tokenizedLine.nextToken();
					action = tokenizedLine.nextToken();
					price = Float.parseFloat(tokenizedLine.nextToken());
					amount = Integer.parseInt(tokenizedLine.nextToken());
					
					synchronized (server) {
						updateStockInfo(stockName, action, price, amount);
					}
					
					outToClient.writeBytes("OK\n");
					connectionSocket.close();
					System.out.println("ok.");
				}
			} catch (Exception e) {
				System.err.println("Error in MessageServer.run(): "
						+ e.getMessage());
			}
		}
	}

}


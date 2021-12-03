# Stock_Trading_App_GDSC
This is an app mainly using the concepts of WEBSOCKETS to get realtime data of stocks and then concurrently display the data graphically.
<br><br>[**App Demo Video**](https://www.youtube.com/watch?v=Zxk13E36YMY)
## Features
- Users can **view realtime data** (Candle Stick Graph) for their selected cryptos.
- Users can also change the **interval** of the Candle Stick of the graph.
- Users can **search** for cryptos.
- Users can also add some cryptos as their **favourites** so that they can access it directly.
- Users can get to know realTime **PRICE** , **HIGH PRICE** , **LOW PRICE** of the crypto. 

## Pages 
### [Landing Page](https://drive.google.com/file/d/1FvkdmqgTt1ADoLN8qDCPdfmdjcp4lkB4/view?usp=drivesdk)
- This page is the first page that you get after launching the app.
- This page has options to search Stocks and also navigate to Favourite Stock Page.
- It also has predefined stocks that are common which are always shown on the app for fast access.
### [Stock Details Page ](https://drive.google.com/file/d/1Fvnzf552keRXcsHO8ZL6Kn8i-JQoEoAZ/view?usp=drivesdk)
- This page shows the the details of the selected stock.
- User can view Candle Stick graph of the stock and also observe **realtime price**, **high price** , **low price** for the stock.
- User can also choose the time interval for the candle Stick grap `[1m 5m 15m 30m 1w 1D 1M]`.
- This page also gives you the option to add the stock to your Favourites List.
### [Favourite Stock Page](https://drive.google.com/file/d/1G8KPiBGpnus9AN7RkivwtQ1hfgthY-aE/view?usp=drivesdk)
- This page shows all the list of stocks that you have set as favourite so that you can access them directly from here reducing the process to search stocks.
<br>
<br>

## Implementation of WEBSOCKET

### Connecting to the WEBSOCKET
`channel = WebSocketChannel.connect(
      Uri.parse('wss://ws.finnhub.io?token=c6av1iaad3ieq36s0q9g'),
    );`
### Sending Request to WEBSOCKET
`channel.sink.add('{"type": "subscribe", "symbol": "${widget.symbol}"}'); `
### Updating the Graph
- Used StreamBuilder to continuosly listen and update changes in the app.


<br>
<br>

## Flow of the Stock Detail Page
- After opening the page the app connects to the **WEBSOCKET**.
- Then an HTTP request is made to get previous data.
- A message is sent to WEBSOCKET which inturns send data
- Used a stream builder to update the widget synchronously with WEBSOCKET
- Based on the Time Interval either a new candle is added or the latest candle is updated.

## Dependencies
- CandleStick widget - to display graph
- Hive - to store favourite cryptocurrencies



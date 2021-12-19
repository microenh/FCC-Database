import Foundation
import Network

@available(macOS 10.14, *)
class ServerConnection {
    
    private static var nextID: Int = 0
    let connection: NWConnection
    let id: Int
    let queue: DispatchQueue
    
    init(nwConnection: NWConnection, queue: DispatchQueue) {
        connection = nwConnection
        self.queue = queue
        id = ServerConnection.nextID
        ServerConnection.nextID += 1
    }
    
    var didStopCallback: ((Error?) -> Void) = {_ in}
    var processMessage: (Data?) -> () = {_ in}
    
    func start() {
        // print("connection \(id) will start")
        connection.stateUpdateHandler = self.stateDidChange(to:)
        setupReceive()
        connection.start(queue: queue)
    }
    
    private func stateDidChange(to state: NWConnection.State) {
        switch state {
        case .waiting(let error):
            connectionDidFail(error: error)
        case .ready:
            // print("connection \(id) ready")
            break
        case .failed(let error):
            connectionDidFail(error: error)
        default:
            break
        }
    }

    private func getHost() ->  NWEndpoint.Host? {
        switch connection.endpoint {
        case .hostPort(let host , _):
            return host
        default:
            return nil
        }
    }
    
    
    private func setupReceive() {
        connection.receiveMessage {[weak self] (data, _, isComplete, error) in
            if let self = self {
                self.processMessage(data)
                if isComplete {
                    self.connectionDidEnd()
                } else if let error = error {
                    self.connectionDidFail(error: error)
//                } else {
//                    self.setupReceive()
                }
            }
        }
    }

    
    func send(data: Data) {
        self.connection.send(content: data, completion: .contentProcessed( { error in
            if let error = error {
                self.connectionDidFail(error: error)
                return
            }
            // print("connection \(self.id) did send, data: \(data as NSData)")
        }))
    }
    
    func stop() {
        // print("connection \(id) will stop")
    }
    
    
    
    private func connectionDidFail(error: Error) {
        // print("connection \(id) did fail, error: \(error)")
        stop(error: error)
    }
    
    private func connectionDidEnd() {
        // print("connection \(id) did end")
        stop(error: nil)
    }
    
    private func stop(error: Error?) {
        connection.stateUpdateHandler = nil
        connection.cancel()
        didStopCallback(error)
        didStopCallback = {_ in}
    }
}

import Foundation
import Network

@available(macOS 10.14, *)
class Server {
    let listener: NWListener
    
    var processMessage: (Data?) -> () = {_ in}
    let queue: DispatchQueue
    
    private var connectionsByID: [Int: ServerConnection] = [:]
    
    init() {
        let port = UserDefaults.standard.integer(forKey: "FCCDatabase.udpPort")
        let endPointPort = NWEndpoint.Port(rawValue: UInt16(port))!
        listener = try! NWListener(using: .udp, on: endPointPort)
        queue = DispatchQueue(label: "udpQ")
    }
    
    func start() throws {
        // print("Server starting...")
        listener.stateUpdateHandler = self.stateDidChange(to:)
        listener.newConnectionHandler = self.didAccept(nwConnection:)
        listener.start(queue: queue)
    }
    
    func stateDidChange(to newState: NWListener.State) {
        switch newState {
        case .ready:
            // print("Server ready.")
            break
        case .failed/* (let error) */:
            // print("Server failure, error: \(error.localizedDescription)")
            exit(EXIT_FAILURE)
        default:
            break
        }
    }
    
    private func didAccept(nwConnection: NWConnection) {
        let connection = ServerConnection(nwConnection: nwConnection, queue: queue)
        self.connectionsByID[connection.id] = connection
        connection.processMessage = self.processMessage
        connection.didStopCallback = { _ in
            self.connectionDidStop(connection)
        }
        connection.start()
        // connection.send(data: "Welcome you are connection: \(connection.id)".data(using: .utf8)!)
        // print("server did open connection \(connection.id)")
    }
    
    private func connectionDidStop(_ connection: ServerConnection) {
        self.connectionsByID.removeValue(forKey: connection.id)
        // print("server did close connection \(connection.id)")
    }
    
    private func stop() {
        self.listener.stateUpdateHandler = nil
        self.listener.newConnectionHandler = nil
        self.listener.cancel()
        for connection in self.connectionsByID.values {
            connection.didStopCallback = {_ in}
            connection.stop()
        }
        self.connectionsByID.removeAll()
    }
}


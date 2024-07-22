use std::io;
use rustls::{client, Connection};

fn main() {
    let mut client = client::ClientSession::new(&rustls::ClientConfig::new(), "example.com");
    let mut socket = connect(client, 443);
    loop {
        if client.wants_read() && socket.ready_for_read() {
          client.read_tls(&mut socket).unwrap();
          client.process_new_packets().unwrap();

          let mut plaintext = Vec::new();
          client.reader().read_to_end(&mut plaintext).unwrap();
          io::stdout().write(&plaintext).unwrap();
        }

        if client.wants_write() && socket.ready_for_write() {
          client.write_tls(&mut socket).unwrap();
        }

        socket.wait_for_something_to_happen();
    }
}

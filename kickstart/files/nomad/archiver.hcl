plugin "docker" {
  config {
    allow_privileged = true
    volumes {
      enabled = true
    }
  }
}

//  Semantics changed?
// client {
//   reserved {
//     cpu    = 1000
//     memory = 3072
//   }
// }
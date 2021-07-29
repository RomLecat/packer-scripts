packer {
    required_plugins {
        windows-update = {
            source = "github.com/rgl/windows-update"
            version = ">= 0.12.0"
        }
    }
}
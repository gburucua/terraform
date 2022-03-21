output "output" {
  value = {
    fsx_arn                            = aws_fsx_windows_file_system.main.arn
    fsx_dns_name                       = aws_fsx_windows_file_system.main.dns_name
    fsx_id                             = aws_fsx_windows_file_system.main.id
    fsx_network_interface_ids          = aws_fsx_windows_file_system.main.network_interface_ids
    fsx_preferred_file_server_ip       = aws_fsx_windows_file_system.main.preferred_file_server_ip
    fsx_remote_administration_endpoint = aws_fsx_windows_file_system.main.remote_administration_endpoint
  }
}

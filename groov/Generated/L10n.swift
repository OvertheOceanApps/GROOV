// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command
// swiftlint:disable file_length

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name
internal enum L10n {
  /// Add
  internal static let add = L10n.tr("Localizable", "Add")
  /// Add Folder
  internal static let addFolder = L10n.tr("Localizable", "AddFolder")
  /// Add New Playlist Folder
  internal static let addPlaylist = L10n.tr("Localizable", "AddPlaylist")
  /// App Description
  internal static let appDescription = L10n.tr("Localizable", "AppDescription")
  /// App Information
  internal static let appInfo = L10n.tr("Localizable", "AppInfo")
  /// Gather and listen your favorite music!
  internal static let appTitleDescription = L10n.tr("Localizable", "AppTitleDescription")
  /// Cancel
  internal static let cancel = L10n.tr("Localizable", "Cancel")
  /// Close
  internal static let close = L10n.tr("Localizable", "Close")
  /// Current Version
  internal static let currentVersion = L10n.tr("Localizable", "CurrentVersion")
  /// Data
  internal static let data = L10n.tr("Localizable", "Data")
  /// Delete
  internal static let delete = L10n.tr("Localizable", "Delete")
  /// Folder List
  internal static let folderList = L10n.tr("Localizable", "FolderList")
  /// Folder / Video Removed
  internal static let folderVideoRemoved = L10n.tr("Localizable", "FolderVideoRemoved")
  /// Add Video
  internal static let goSearchVideo = L10n.tr("Localizable", "GoSearchVideo")
  /// Image Cache Removed
  internal static let imageCacheRemoved = L10n.tr("Localizable", "ImageCacheRemoved")
  /// add_folder_2_english
  internal static let imgAddFolder = L10n.tr("Localizable", "ImgAddFolder")
  /// video_search_english
  internal static let imgSearchVideo = L10n.tr("Localizable", "ImgSearchVideo")
  /// Add New Folder
  internal static let msgAddNewFolder = L10n.tr("Localizable", "MsgAddNewFolder")
  /// Search / Add New Video
  internal static let msgAddNewVideo = L10n.tr("Localizable", "MsgAddNewVideo")
  /// No Recent Video
  internal static let noRecentVideo = L10n.tr("Localizable", "NoRecentVideo")
  /// Open Source Library
  internal static let openSourceLibrary = L10n.tr("Localizable", "OpenSourceLibrary")
  /// Remove Folder/Video
  internal static let removeFolderVideo = L10n.tr("Localizable", "RemoveFolderVideo")
  /// Remove Image Cache
  internal static let removeImageCache = L10n.tr("Localizable", "RemoveImageCache")
  /// Search Video
  internal static let searchVideo = L10n.tr("Localizable", "SearchVideo")
  /// Send Mail To @pilgwon
  internal static let sendMail = L10n.tr("Localizable", "SendMail")
  /// Settings
  internal static let settings = L10n.tr("Localizable", "Settings")
  /// Video Added
  internal static let videoAddComplete = L10n.tr("Localizable", "VideoAddComplete")
  /// Video List
  internal static let videoList = L10n.tr("Localizable", "VideoList")
  /// Visit Facebook
  internal static let visitFacebook = L10n.tr("Localizable", "VisitFacebook")
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name

// MARK: - Implementation Details

extension L10n {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg...) -> String {
    // swiftlint:disable:next nslocalizedstring_key
    let format = NSLocalizedString(key, tableName: table, bundle: Bundle(for: BundleToken.self), comment: "")
    return String(format: format, locale: Locale.current, arguments: args)
  }
}

private final class BundleToken {}

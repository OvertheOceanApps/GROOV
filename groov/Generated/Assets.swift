// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

#if os(OSX)
  import AppKit.NSImage
  internal typealias AssetColorTypeAlias = NSColor
  internal typealias AssetImageTypeAlias = NSImage
#elseif os(iOS) || os(tvOS) || os(watchOS)
  import UIKit.UIImage
  internal typealias AssetColorTypeAlias = UIColor
  internal typealias AssetImageTypeAlias = UIImage
#endif

// swiftlint:disable superfluous_disable_command
// swiftlint:disable file_length

// MARK: - Asset Catalogs

// swiftlint:disable identifier_name line_length nesting type_body_length type_name
internal enum Asset {
  internal static let addFolder2 = ImageAsset(name: "add_folder_2")
  internal static let addFolder2English = ImageAsset(name: "add_folder_2_english")
  internal static let addFolder2Japanese = ImageAsset(name: "add_folder_2_japanese")
  internal static let addFolder2Simplified = ImageAsset(name: "add_folder_2_simplified")
  internal static let addFolder2Traditional = ImageAsset(name: "add_folder_2_traditional")
  internal static let addFolderThumbnail = ImageAsset(name: "add_folder_thumbnail")
  internal static let loadingGradation = ImageAsset(name: "loading_gradation")
  internal static let loadingGradationMiddle = ImageAsset(name: "loading_gradation_middle")
  internal static let loadingGradationShort = ImageAsset(name: "loading_gradation_short")
  internal static let navigationAdd = ImageAsset(name: "navigation_add")
  internal static let navigationBack2 = ImageAsset(name: "navigation_back-2")
  internal static let navigationBack = ImageAsset(name: "navigation_back")
  internal static let navigationDismiss = ImageAsset(name: "navigation_dismiss")
  internal static let navigationSearch = ImageAsset(name: "navigation_search")
  internal static let navigationSetting = ImageAsset(name: "navigation_setting")
  internal static let searchClose = ImageAsset(name: "search_close")
  internal static let searchFavicon = ImageAsset(name: "search_favicon")
  internal static let searchUnderLine = ImageAsset(name: "search_under_line")
  internal static let sideMenuToggle = ImageAsset(name: "side_menu_toggle")
  internal static let videoControlBackground = ImageAsset(name: "video_control_background")
  internal static let videoControlForward = ImageAsset(name: "video_control_forward")
  internal static let videoControlPause = ImageAsset(name: "video_control_pause")
  internal static let videoControlPlay = ImageAsset(name: "video_control_play")
  internal static let videoControlPrevious = ImageAsset(name: "video_control_previous")
  internal static let videoListCellPause = ImageAsset(name: "video_list_cell_pause")
  internal static let videoListCellPlay = ImageAsset(name: "video_list_cell_play")
  internal static let videoSearch = ImageAsset(name: "video_search")
  internal static let videoSearchEnglish = ImageAsset(name: "video_search_english")
  internal static let videoSearchJapanese = ImageAsset(name: "video_search_japanese")
  internal static let videoSearchSimplified = ImageAsset(name: "video_search_simplified")
  internal static let videoSearchTraditional = ImageAsset(name: "video_search_traditional")
}
// swiftlint:enable identifier_name line_length nesting type_body_length type_name

// MARK: - Implementation Details

internal struct ColorAsset {
  internal fileprivate(set) var name: String

  @available(iOS 11.0, tvOS 11.0, watchOS 4.0, OSX 10.13, *)
  internal var color: AssetColorTypeAlias {
    return AssetColorTypeAlias(asset: self)
  }
}

internal extension AssetColorTypeAlias {
  @available(iOS 11.0, tvOS 11.0, watchOS 4.0, OSX 10.13, *)
  convenience init!(asset: ColorAsset) {
    let bundle = Bundle(for: BundleToken.self)
    #if os(iOS) || os(tvOS)
    self.init(named: asset.name, in: bundle, compatibleWith: nil)
    #elseif os(OSX)
    self.init(named: NSColor.Name(asset.name), bundle: bundle)
    #elseif os(watchOS)
    self.init(named: asset.name)
    #endif
  }
}

internal struct DataAsset {
  internal fileprivate(set) var name: String

  #if os(iOS) || os(tvOS) || os(OSX)
  @available(iOS 9.0, tvOS 9.0, OSX 10.11, *)
  internal var data: NSDataAsset {
    return NSDataAsset(asset: self)
  }
  #endif
}

#if os(iOS) || os(tvOS) || os(OSX)
@available(iOS 9.0, tvOS 9.0, OSX 10.11, *)
internal extension NSDataAsset {
  convenience init!(asset: DataAsset) {
    let bundle = Bundle(for: BundleToken.self)
    #if os(iOS) || os(tvOS)
    self.init(name: asset.name, bundle: bundle)
    #elseif os(OSX)
    self.init(name: NSDataAsset.Name(asset.name), bundle: bundle)
    #endif
  }
}
#endif

internal struct ImageAsset {
  internal fileprivate(set) var name: String

  internal var image: AssetImageTypeAlias {
    let bundle = Bundle(for: BundleToken.self)
    #if os(iOS) || os(tvOS)
    let image = AssetImageTypeAlias(named: name, in: bundle, compatibleWith: nil)
    #elseif os(OSX)
    let image = bundle.image(forResource: NSImage.Name(name))
    #elseif os(watchOS)
    let image = AssetImageTypeAlias(named: name)
    #endif
    guard let result = image else { fatalError("Unable to load image named \(name).") }
    return result
  }
}

internal extension AssetImageTypeAlias {
  @available(iOS 1.0, tvOS 1.0, watchOS 1.0, *)
  @available(OSX, deprecated,
    message: "This initializer is unsafe on macOS, please use the ImageAsset.image property")
  convenience init!(asset: ImageAsset) {
    #if os(iOS) || os(tvOS)
    let bundle = Bundle(for: BundleToken.self)
    self.init(named: asset.name, in: bundle, compatibleWith: nil)
    #elseif os(OSX)
    self.init(named: NSImage.Name(asset.name))
    #elseif os(watchOS)
    self.init(named: asset.name)
    #endif
  }
}

private final class BundleToken {}

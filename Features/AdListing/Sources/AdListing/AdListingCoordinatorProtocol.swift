//
//  AdListingCoordinatorProtocol.swift
//  AdListing
//
//  Created by Julien Cholin on 29/11/2024.
//

import Foundation
import Domain
import SwiftUI

public protocol AdListingCoordinatorProtocol: AnyObject {
	func navigateToAdDetailSwiftUI(ad: Ad)
	func navigateToAdDetailUIKit(ad: Ad)
}

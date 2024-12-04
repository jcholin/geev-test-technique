//
//  AppDI.swift
//  GeevTestTechnique
//
//  Created by Julien Cholin on 02/12/2024.
//

import Factory
import Api
import AdListing
import AdDetail
import Domain
import Data

public extension Container {
	var networkService: Factory<NetworkService> {
		self { NetworkService() }.singleton
	}

	var adRemoteDataSource: Factory<AdRemoteDataSourceProtocol> {
		self { AdRemoteDataSource(networkService: self.networkService()) }
	}

	var adListingViewModel: Factory<AdListingViewModel> {
		self { AdListingViewModel(repository: self.adRepository()) }
	}

	var adDetailViewModel: ParameterFactory<String, AdDetailViewModel> {
		ParameterFactory(self) { adId in
			AdDetailViewModel(
				repository: self.adRepository(),
				adId: adId
			)
		}
	}

	var adRepository: Factory<AdRepositoryProtocol> {
		self { AdRepository(remoteDataSource: self.adRemoteDataSource()) }
	}
}

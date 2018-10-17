#include <iostream>
#include "tools.h"

using Eigen::VectorXd;
using Eigen::MatrixXd;
using std::vector;

Tools::Tools() {}

Tools::~Tools() {}

VectorXd Tools::CalculateRMSE(const vector<VectorXd> &estimations,
							  const vector<VectorXd> &ground_truth) {
  /**
  TODO:
	* Calculate the RMSE here.
  */
	VectorXd rmse(4);
	rmse << 0, 0, 0, 0;

	// check the validity of the following inputs:
	//  * the estimation vector size should not be zero
	//  * the estimation vector size should equal ground truth vector size
	if (estimations.size() != ground_truth.size()
		|| estimations.size() == 0) {
		cout << "Invalid estimation or ground_truth data" << endl;
		return rmse;
	}

	//accumulate squared residuals
	for (unsigned int i = 0; i < estimations.size(); ++i) {

		VectorXd residual = estimations[i] - ground_truth[i];

		//coefficient-wise multiplication
		residual = residual.array()*residual.array();
		rmse += residual;
	}

	//calculate the mean
	rmse = rmse / estimations.size();

	//calculate the squared root
	rmse = rmse.array().sqrt();

	//return the result
	return rmse;
}

VectorXd Tools::ConvertPolarToCartesian(const VectorXd &raw_measurements_) {
	float rho = raw_measurements_[0]; // range
	float phi = raw_measurements_[1]; // bearing
	float rho_dot = raw_measurements_[2]; // velocity of rho
	// Coordinates convertion from polar to cartesian
	float x = rho * cos(phi);
	if (x < 0.0001) {
		x = 0.0001;
	}
	float y = rho * sin(phi);
	if (y < 0.0001) {
		y = 0.0001;
	}
	/*double vx = rho_dot * cos(phi);
	double vy = rho_dot * sin(phi);*/
	VectorXd x_ = VectorXd(5);
	x_ << x, y, 0, 0, 0;

	return x_;
}
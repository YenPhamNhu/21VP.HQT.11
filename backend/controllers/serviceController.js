const serviceData = require("../data/services");

// Create a map of service IDs to service objects
const serviceMap = {};

const getAllService = async (req, res, next) => {
  try {
    const servicelist = await serviceData.getService();
    for (const service of servicelist) {
      serviceMap[service.MaDichVu] = service;
    }
    res.send(servicelist);
  } catch (error) {
    res.status(400).send(error.message);
  }
};

const getServiceById = async (req, res, next) => {
  try {
    const servicelist = await serviceData.getService();
    for (const service of servicelist) {
      serviceMap[service.MaDichVu] = service;
    }
    const serviceId = req.params.MaDichVu;
    console.log("MaDichVu:", serviceMap[serviceId]);
    const service = serviceMap[serviceId];

    if (!service) {
      res.status(404).send("Service not found");
      return;
    }

    res.send(service);
  } catch (error) {
    res.status(400).send(error.message);
  }
};

// dich vu su dung
const service_usagesData = require("../data/service_usages");
const getAllServiceUsage = async (req, res, next) => {
  try {
    const service_usages_list = await service_usagesData.getServiceUsage();
    res.send(service_usages_list);
  } catch (error) {
    res.status(400).send(error.message);
  }
};

module.exports = {
  getAllService,
  getServiceById,
  // deleteAllUser,

  getAllServiceUsage,
};
